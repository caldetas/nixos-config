{ config, pkgs, lib, host, ... }:
with lib;
with host;

let
  bundle = pkgs.fetchzip {
    url = "https://github.com/caldetas/surfshark/archive/refs/heads/main.zip";
    sha256 = "sha256-MCtHbCRA17tvKv7qMf3zNcoQih6Oxxih21QZUNQ/Z4Q=";
    stripRoot = true; # GitHub archives have a single top dir
  };
  configFiles = pkgs.stdenv.mkDerivation {
    name = "surfshark-config";
    phases = [ "installPhase" ];
    buildInputs = [ pkgs.findutils pkgs.gnused pkgs.coreutils ];
    installPhase = ''
          set -euo pipefail
          cfgdir=${bundle}/configurations
          mkdir -p "$out"

          # copy ONLY UDP profiles and write them as $out/<short>.ovpn (e.g. ch-zur.ovpn)
          while IFS= read -r -d $'\0' f; do
            base="$(basename "$f")"
            short="$(printf '%s' "$base" | sed 's/\.prod\.surfshark\.com_udp\.ovpn$/.ovpn/')"
            install -Dm0644 "$f" "$out/$short"
          done < <(find "$cfgdir" -type f -name '*_udp.ovpn' -print0)

          # patch each file: inject secret path and update cipher directive
          while IFS= read -r -d $'\0' f; do
            sed -i 's|^auth-user-pass$|auth-user-pass "'"${config.sops.secrets."surfshark/openvpn".path}"'"|' "$f"
            sed -i 's/^cipher/data-ciphers-fallback/' "$f"
          done < <(find "$out" -type f -name '*.ovpn' -print0)

      # --- extra OpenVPN hardening/tuning directives (append-if-missing) ---
      while IFS= read -r -d $'\0' f; do
        ensure() {
          local pattern="$1"
          local line="$2"
          grep -qE "$pattern" "$f" || echo "$line" >> "$f"
        }

        # make sure file ends with newline before appending
        if [ -n "$(tail -c1 "$f" 2>/dev/null || true)" ]; then
          echo >> "$f"
        fi

        ensure '^redirect-gateway(\\s|$)'        'redirect-gateway def1'

        # VPN DNS servers
        ensure '^dhcp-option DNS 162\\.252\\.172\\.57(\\s|$)' 'dhcp-option DNS 162.252.172.57'
        ensure '^dhcp-option DNS 149\\.154\\.159\\.92(\\s|$)' 'dhcp-option DNS 149.154.159.92'

        # Keepalive / persistence
        ensure '^persist-tun(\\s|$)'             'persist-tun'
        ensure '^persist-key(\\s|$)'             'persist-key'

          # replace if present, else append
          grep -qE '^tun-mtu(\s|$)' "$f" && sed -i -E 's/^tun-mtu(\s+).*/tun-mtu 1360/' "$f" || echo 'tun-mtu 1360' >> "$f"
          grep -qE '^mssfix(\s|$)'  "$f" && sed -i -E 's/^mssfix(\s+).*/mssfix 1320/'  "$f" || echo 'mssfix 1320'  >> "$f"
          grep -qE '^ping(\s|$)'    "$f" && sed -i -E 's/^ping(\s+).*/ping 20/'        "$f" || echo 'ping 20'        >> "$f"
          grep -qE '^ping-restart(\s|$)' "$f" && sed -i -E 's/^ping-restart(\s+).*/ping-restart 300/' "$f" || echo 'ping-restart 300' >> "$f"
      done < <(find "$out" -type f -name '*.ovpn' -print0)
      # --- end hardening block ---
    '';
  };

  # avoid readDir-on-derivation during eval; list profiles you need
  profiles = [ "ch-zur" "de-fra" "no-osl" "us-phx" ];

  getConfig = name: {
    inherit name;
    value = {
      # pass a path string; do NOT read the file at eval time
      config = "config ${configFiles}/${name}.ovpn";
      autoStart = (builtins.match ".*ch-zur.*" name) != null;
    };
  };

  serversAttr = builtins.listToAttrs (map getConfig profiles);
in
{
  options.surfshark.enable = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf config.surfshark.enable {
    networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
    services.openvpn.servers = serversAttr;
    services.resolved = { enable = true; dnssec = "allow-downgrade"; domains = [ "~." ]; };
  };
  #  countries
  #  ad-leu.ovpn  au-syd.ovpn  bs-nas.ovpn  cy-nic.ovpn  es-mad.ovpn  hk-hkg.ovpn  it-mil.ovpn  lu-ste.ovpn  mt-mla.ovpn  ph-mnl.ovpn  sa-ruh.ovpn  uk-gla.ovpn  us-dal.ovpn  us-phx.ovpn
  #  ae-dub.ovpn  az-bak.ovpn  bt-pbh.ovpn  cz-prg.ovpn  es-vlc.ovpn  hr-zag.ovpn  it-rom.ovpn  lv-rig.ovpn  mx-qro.ovpn  pk-khi.ovpn  se-sto.ovpn  uk-lon.ovpn  us-den.ovpn  us-sea.ovpn
  #  al-tia.ovpn  ba-sjj.ovpn  bz-blp.ovpn  de-ber.ovpn  fi-hel.ovpn  hu-bud.ovpn  jp-tok.ovpn  ma-rab.ovpn  my-kul.ovpn  pl-gdn.ovpn  sg-sng.ovpn  uk-man.ovpn  us-dtw.ovpn  us-sfo.ovpn
  #  am-evn.ovpn  bd-dac.ovpn  ca-mon.ovpn  de-fra.ovpn  fr-bod.ovpn  id-jak.ovpn  kh-pnh.ovpn  mc-mcm.ovpn  ng-lag.ovpn  pl-waw.ovpn  si-lju.ovpn  us-ash.ovpn  us-hou.ovpn  us-sjc.ovpn
  #  ar-bua.ovpn  be-anr.ovpn  ca-tor.ovpn  dk-cph.ovpn  fr-mrs.ovpn  ie-dub.ovpn  kr-seo.ovpn  md-chi.ovpn  nl-ams.ovpn  pr-sju.ovpn  sk-bts.ovpn  us-atl.ovpn  us-kan.ovpn  us-slc.ovpn
  #  at-vie.ovpn  be-bru.ovpn  ca-van.ovpn  dz-alg.ovpn  fr-par.ovpn  il-tlv.ovpn  kz-ura.ovpn  me-tgd.ovpn  no-osl.ovpn  pt-lis.ovpn  th-bkk.ovpn  us-bdn.ovpn  us-las.ovpn  uy-mvd.ovpn
  #  au-adl.ovpn  bg-sof.ovpn  ch-zur.ovpn  ec-uio.ovpn  ge-tbs.ovpn  im-iom.ovpn  la-vte.ovpn  mk-skp.ovpn  np-ktm.ovpn  pt-opo.ovpn  tr-ist.ovpn  us-bos.ovpn  us-lax.ovpn  uz-tas.ovpn
  #  au-bne.ovpn  bn-bwn.ovpn  cl-san.ovpn  ee-tll.ovpn  gh-acc.ovpn  in-del.ovpn  li-qvu.ovpn  mm-nyt.ovpn  nz-akl.ovpn  py-asu.ovpn  tw-tai.ovpn  us-buf.ovpn  us-ltm.ovpn  ve-car.ovpn
  #  au-mel.ovpn  bo-sre.ovpn  co-bog.ovpn  eg-cai.ovpn  gl-goh.ovpn  in-mum.ovpn  lk-cmb.ovpn  mn-uln.ovpn  pa-pac.ovpn  ro-buc.ovpn  ua-iev.ovpn  us-chi.ovpn  us-mia.ovpn  vn-hcm.ovpn
  #  au-per.ovpn  br-sao.ovpn  cr-sjn.ovpn  es-bcn.ovpn  gr-ath.ovpn  is-rkv.ovpn  lt-vno.ovpn  mo-mfm.ovpn  pe-lim.ovpn  rs-beg.ovpn  uk-edi.ovpn  us-clt.ovpn  us-nyc.ovpn  za-jnb.ovpn
}
