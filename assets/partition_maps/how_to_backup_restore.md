## Backup GPT

sfdisk --dump /dev/sda > \<file>

## Backup MBR

sfdisk --dump /dev/sda > \<file>

## Restore GPT

sfdisk /dev/sda < \<file>

## Restore MBR

sfdisk /dev/sda < \<file>
