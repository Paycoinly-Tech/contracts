./build.sh

source .env
source .env.key

export VERSION=0
export PRIVATE_KEY=$PRIVATE_KEY

# echo "Deploying contract on Sepolia"
# forge script script/DeployAmbxPay.s.sol --rpc-url $RPC_SEPOLIA --verify --slow --broadcast

echo "Deploying contract on Mainnet"
forge script script/DeployAmbxPay.s.sol --rpc-url $RPC_MAINNET --verify --slow --broadcast

# echo "Deploying contract on Arbitrum"
# forge script script/DeployAmbxPay.s.sol --rpc-url $RPC_ARBITRUM --verify --slow --broadcast

# echo "Deploying contract on BnbChain"
# forge script script/DeployAmbxPay.s.sol --rpc-url $RPC_BNB --verify --slow --broadcast