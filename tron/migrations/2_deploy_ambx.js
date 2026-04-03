const ProxyAdmin = artifacts.require(
  '@openzeppelin/upgrades-core/artifacts/@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol/ProxyAdmin.json'
);
const TransparentUpgradeableProxy = artifacts.require(
  '@openzeppelin/upgrades-core/artifacts/@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol/TransparentUpgradeableProxy.json'
);
const AmbxPay = artifacts.require('AmbxPay');

module.exports = async function (deployer, network, account) {
  if (network === 'test') {
    return
  }

  try {
    await deployer.deploy(ProxyAdmin)
    const proxyAdmin = await ProxyAdmin.deployed();
    console.log("ProxyAdmin deployed at:", proxyAdmin.address);

    await deployer.deploy(AmbxPay);
    const ambxPay = await AmbxPay.deployed();
    console.log("AmbxPay deployed at:", ambxPay.address);

    await deployer.deploy(
      TransparentUpgradeableProxy,
      ambxPay.address,
      proxyAdmin.address,
      "0x"
    );
    const proxy = await TransparentUpgradeableProxy.deployed();
    console.log("TransparentUpgradeableProxy deployed at:", proxy.address)

    const proxied = await AmbxPay.at(proxy.address);
    await proxied.initialize(account, 0)
  } catch (error) {
    console.error('Transparent: deploy AmbxPay error', error);
  }
};