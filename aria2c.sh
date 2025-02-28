#! /bin/bash -eu

sed -i 's/6800/'"${ARIA2_EXTERNAL_PORT}"'/g' /usr/local/www/aria2/js/aria-ng*.js
RPC_SECRET_BASE64=$(echo -n ${RPC_SECRET}|base64)
sed -i 's/secret:\"\"/secret:\"'"${RPC_SECRET_BASE64}"'\"/g' /usr/local/www/aria2/js/aria-ng*.js

list=`wget -qO- https://trackerslist.com/all_aria2.txt|awk NF|sed ":a;N;s/\n/,/g;ta"`
if [ -n "$list" ]; then
    # 把 trackers 更新到 aria2 的配置文件中
    sed -i "" "s@bt-tracker.*@bt-tracker=$list@g" /app/conf/aria2.conf
fi

if [ "$ARIA2_SSL" = "true" ]; then
echo "[INFO] Start aria2 with secure config"

/usr/bin/aria2c --conf-path="/app/conf/aria2.conf" \
--enable-rpc --rpc-listen-all \
--rpc-certificate=/app/conf/key/aria2.crt \
--rpc-private-key=/app/conf/key/aria2.key \
--rpc-secret="$RPC_SECRET" --rpc-secure \

else

echo "[INFO] Start aria2 with standard mode"
/usr/bin/aria2c --conf-path="/app/conf/aria2.conf" --enable-rpc --rpc-listen-all

fi
