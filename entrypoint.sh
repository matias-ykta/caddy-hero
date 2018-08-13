cd /file
unzip config.zip

date -R
SYS_Bit="$(getconf LONG_BIT)"
[[ "$SYS_Bit" == '32' ]] && BitVer='_linux_386.tar.gz'
[[ "$SYS_Bit" == '64' ]] && BitVer='_linux_amd64.tar.gz'

if [ "$VER" = "latest" ]; then
  V2_TAG_URL="https://api.github.com/repos/v2ray/v2ray-core/releases/latest"
  VER_1=`wget -qO- "$V2_TAG_URL" | grep 'tag_name' | cut -d\" -f4`
else
  VER_1="v$VER"
fi

#下载v2ray core
mkdir /v2raybin
cd /v2raybin
wget --no-check-certificate -qO 'v2ray.zip' "https://github.com/v2ray/v2ray-core/releases/download/$VER_1/v2ray-linux-$SYS_Bit.zip"
unzip v2ray.zip
cd /v2raybin/v2ray-$VER_1-linux-$SYS_Bit
chmod +x v2ray
chmod +x v2ctl
rm -rf v2ray.zip

#下载caddy
CADDY_TAG_URL="https://api.github.com/repos/mholt/caddy/releases/latest"
CADDY_VER=`wget -qO- "$CADDY_TAG_URL" | grep 'tag_name' | cut -d\" -f4`
mkdir /caddybin
mkdir /caddybin/caddy_$CADDY_VER
cd /caddybin/caddy_$CADDY_VER
wget --no-check-certificate -qO 'caddy.tar.gz' "https://github.com/mholt/caddy/releases/download/$CADDY_VER/caddy_$CADDY_VER$BitVer"
tar xvf caddy.tar.gz
chmod +x caddy
rm -rf caddy.tar.gz
mkdir /wwwroot
cd /wwwroot
wget --no-check-certificate -qO 'demo.tar.gz' https://github.com/ki8852/v2ray-heroku/raw/master/demo.tar.gz
tar xvf demo.tar.gz
rm -rf demo.tar.gz

#v2ray配置并启动v2ray
cd /v2raybin/v2ray-$VER_1-linux-$SYS_Bit
CONFIG_JSON1=$(cat /file/1.json)
CONFIG_JSON2=$(cat /file/2.json)
CONFIG_JSON3=$(cat /file/3.json)
echo -e -n "$CONFIG_JSON1" > config.json
echo -e -n "$UUID" >> config.json
echo -e -n "$CONFIG_JSON2" >> config.json
echo -e -n "$V2_PATH" >> config.json
echo -e -n "$CONFIG_JSON3" >> config.json
./v2ray &

#caddy配置并启动caddy
cd /caddybin/caddy_$CADDY_VER
CONFG1=$(cat /file/c1.confg)
CONFG2=$(cat /file/c2.confg)
CONFG3=$(cat /file/c3.confg)
echo -e -n "$CONFG1" > HerokuCaddyfile
echo -e -n "$PORT" >> HerokuCaddyfile
echo -e -n "$CONFG2" >> HerokuCaddyfile
echo -e -n "$V2_PATH" >> HerokuCaddyfile
echo -e -n "$CONFG3" >> HerokuCaddyfile
./caddy -conf="HerokuCaddyfile"
