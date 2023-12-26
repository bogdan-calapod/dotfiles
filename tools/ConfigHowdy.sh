# !/bin/bash
# Reference: https://copr.fedorainfracloud.org/coprs/principis/howdy/

# sudo required
if ! [ $(id -u) = 0 ]; then
   echo "Root privilege is needed. Please rerun the script as root." >&2
   exit 1
fi

SUDO_CFG="/etc/pam.d/sudo"
GDM_CFG="/etc/pam.d/gdm-password"
SUDO_PATTERN='1i\' # Append to the first line
GDM_PATTERN='/auth.*substack.*password-auth/i\' # Append before password-auth line
HOWDY_PAM="auth        sufficient    pam_python.so /lib64/security/howdy/pam.py"
HOWDY_DLIB="/lib64/security/howdy/dlib-data"

# Configure sudo
sed -i "$SUDO_PATTERN$HOWDY_PAM" $SUDO_CFG

# Configure GDM
sed -i "$GDM_PATTERN$HOWDY_PAM" $GDM_CFG

# Configure Permission
chmod o+x $HOWDY_DLIB

# Configure SELinux
MODULE=$(cat << EOF
module howdy 1.0;

require {
    type lib_t;
    type xdm_t;
    type v4l_device_t;
    type sysctl_vm_t;
    class chr_file map;
    class file { create getattr open read write };
    class dir add_name;
}

#============= xdm_t ==============
allow xdm_t lib_t:dir add_name;
allow xdm_t lib_t:file { create write };
allow xdm_t sysctl_vm_t:file { getattr open read };
allow xdm_t v4l_device_t:chr_file map;
EOF
)

echo "$MODULE" > howdy.te
checkmodule -M -m -o howdy.mod howdy.te
semodule_package -o howdy.pp -m howdy.mod
semodule -i howdy.pp
rm howdy.te howdy.mod howdy.pp

# Done!
echo Done. Please restart terminal to check sudo result.
