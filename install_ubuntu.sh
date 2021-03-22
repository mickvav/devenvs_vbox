/bin/bash

vmname=ubuntu20
vdipath=`pwd`/.vdi
vdiname=${vdipath}/${vmname}.vdi
vm_user=`whoami`
echo "Enter password for ${vm_user} on future vm:"
read -s vm_password
mkdir "${vdipath}" || echo "VDI path already exists"
vdisize=10240
ubuntu_image=ubuntu-20.04.2.0-desktop-amd64.iso
ubuntu_version=20.04
isopath=`pwd`/.iso/ubuntu/${ubuntu_version}
isoname=${isopath}/${ubuntu_image}
sumsname=${isopath}/SHA256SUMS
mkdir -p "${isopath}/ubuntu/${ubuntu_version}" || echo "ISO path already exists"
if [ ! "$SKIP_CHECKSUMS" = "yes" ]; then 
  echo "Refreshing checksum of iso image"
  curl -o ${sumsname} https://releases.ubuntu.com/${ubuntu_version}/SHA256SUMS
  if [ -f ${isoname} ]; then
    expected=`grep "${ubuntu_image}" "${sumsname}"|awk '{print $1;}'`
    actual=`shasum $isoname | awk '{print $1;}'`
    if [ "$expected" = "$actual" ]; then
      echo "Checksums match"
    else
      echo "Checksums differ, putting existing file aside"
      mv ${ubuntu_image} ${ubuntu_image}.bak
    fi
  fi
fi

if [ ! -f ${isoname} ]; then
  curl -o ${isoname} https://releases.ubuntu.com/${ubuntu_version}/${ubuntu_image}
fi
memory=2048

VBoxManage createvm --name $vmname --ostype Ubuntu_64 --register
VBoxManage createmedium --filename $vdiname --size $vdisize
VBoxManage storagectl $vmname --name SATA --add SATA --controller IntelAhci
VBoxManage storageattach $vmname --storagectl SATA --port 0 --device 0 --type hdd --medium $vdiname
VBoxManage storagectl $vmname --name IDE --add ide
VBoxManage storageattach $vmname --storagectl IDE --port 0 --device 0 --type dvddrive --medium $isoname
VBoxManage modifyvm $vmname --memory $memory --vram 32
VBoxManage modifyvm $vmname --ioapic on

VBoxManage modifyvm $vmname --boot1 dvd --boot2 disk --boot3 none --boot4 none
VBoxManage modifyvm $vmname --cpus 2
VBoxManage modifyvm $vmname --audio none
VBoxManage modifyvm $vmname --nic1 nat
VBoxManage modifyvm $vmname --natpf1 ssh,tcp,127.0.0.1,2022,10.0.2.15,22
echo "Unattended:"
VBoxManage unattended install $vmname --user=${vm_user} --password=${vm_password} --country=IE --time-zone=GMT --hostname=server01.example.com --iso=${isoname} --start-vm=gui --no-install-additions --full-user-name=${vm_user}

echo "When install will be done, please do (inside guest):"
echo "su"
echo "echo \"${vm_user} ALL=(ALL) ALL\" >> /etc/sudoers"
echo "apt-get install openssh-server git"
echo "echo -ne \"PubkeyAuthentication yes\\nAuthorizedKeysFile	.ssh/authorized_keys .ssh/authorized_keys2\\n\" >> /etc/ssh/sshd_config.d/allow_public_key"
echo "/etc/init.d/ssh restart"
echo "Press enter to continue when this will be done"
ssh-copy-id -p 2022 ${vm_user}@127.0.0.1
ssh -p 2022 ${vm_user}@127.0.0.1 "git clone https://github.com/mickvav/devenvs_vbox.git && cd devenvs_vbox && ./postinstall.sh"
