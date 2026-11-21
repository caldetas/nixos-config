## How to move gradient CI to new VPS

### Set up new vps

### Vpsfree new VPS Node  

Total available CPU: 32  
Total available RAM: 16 GB  
Total available disk: 320 GB  

create node in staging via admin interface vpsfree  
or clone existing node  
choose nixos-unstable as OS

### Activate gradient-ci 

The following preparations should be made:
  - comment out triggers and actions in gradient.nix
  - delete existing github app from old gradient-ci installation on github

Enable gradient-ci and rebuild

Post setup tasks:
  - Create read API token in admin user settings and safe it in common secrets as *gradient/deploy-key*
  - Create Github app (project->nix-fleet->settings->integration) and activate
  - Reinstate triggers and actions in gradient.nix
