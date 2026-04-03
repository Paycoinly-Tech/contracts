const ProxyAdmin = artifacts.require(
  '@openzeppelin/upgrades-core/artifacts/@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol/ProxyAdmin.json'
);
const AmbxPay_V_Mock = artifacts.require('AmbxPay_V_Mock');

module.exports = async function (deployer, network, account) {
  if (network === 'test') {
    return
  }

  if (network !== 'development') {
    return
  }

  try {
    await deployer.deploy(AmbxPay_V_Mock);
    const implV2 = await AmbxPay_V_Mock.deployed();
    console.log("ImplementationV2 deployed at:", implV2.address);

    const proxyAdmin = await ProxyAdmin.at(process.env.PROXY_ADMIN_ADDRESS);
    await proxyAdmin.upgrade(process.env.PROXY_ADDRESS, implV2.address);
    console.log("Proxy upgraded to V2");

    const newVersion = await AmbxPay_V_Mock.at(process.env.PROXY_ADDRESS);
    await newVersion.reinitializeV2(account, 1);
  } catch (error) {
    console.error('Transparent: upgrade error', error);
  }
};
