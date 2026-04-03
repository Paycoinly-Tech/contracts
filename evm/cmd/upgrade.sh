./build.sh

source .env
source .env.key

PROXY_SEPOLIA=0x

export VERSION=1

export PROXY_ADDRESS=$PROXY_SEPOLIA
echo "Upgrading contract on Sepolia at proxy address: $PROXY_ADDRESS"
forge script script/UpgradeAmbxPay.s.sol --private-key $PRIVATE_KEY --rpc-url $RPC_SEPOLIA --verify --slow --broadcast
