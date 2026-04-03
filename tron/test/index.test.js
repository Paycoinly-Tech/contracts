const ProxyAdmin = artifacts.require(
  '@openzeppelin/upgrades-core/artifacts/@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol/ProxyAdmin.json'
);
const TransparentUpgradeableProxy = artifacts.require(
  '@openzeppelin/upgrades-core/artifacts/@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol/TransparentUpgradeableProxy.json'
);

const Token = artifacts.require('Token');

const AmbxPay = artifacts.require('AmbxPay');

const AmbxPay_V_Mock = artifacts.require('AmbxPay_V_Mock');

contract('test', async ([alice, bob]) => {
  it('upgradeability', async () => {
    const proxyAdmin = await ProxyAdmin.new()
    const ambxPay = await AmbxPay.new();
    const proxy = await TransparentUpgradeableProxy.new(ambxPay.address, proxyAdmin.address, "0x");
    const proxied = await AmbxPay.at(proxy.address);
    await proxied.initialize(alice, 1)

    let admin = await proxied.admin()
    let version = await proxied.version()

    assert.equal(tronWeb.address.fromHex(admin), alice)
    assert.equal(version, 1)

    const implV2 = await AmbxPay_V_Mock.new();
    await proxyAdmin.upgrade(proxy.address, implV2.address);
    const newVersion = await AmbxPay_V_Mock.at(proxy.address);
    await newVersion.reinitializeV2(alice, 2);

    admin = await proxied.admin()
    version = await proxied.version()

    assert.equal(tronWeb.address.fromHex(admin), alice)
    assert.equal(version, 2)

    const pay = await newVersion.pay()
    const withdraw = await newVersion.withdraw()
    const anotherFunc = await newVersion.anotherFunctionAdded()

    assert.equal(pay, 'pay_upgraded_mock')
    assert.equal(withdraw, 'pay_upgraded_withdraw_mock')
    assert.equal(anotherFunc, 'anotherFunctionAdded_mock')
  })
})
