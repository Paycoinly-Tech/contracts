const Token = artifacts.require('Token');

module.exports = async function (deployer, network) {
  if (network === 'test') {
    return
  }

  try {
    deployer.deploy(Token, 'Token', 'Token')
  } catch (error) {
    console.error('Deploy mock token error', error);
  }
};