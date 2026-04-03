import { privateKeyToAccount } from 'viem/accounts'
import { keccak256, toBytes } from 'viem'
import { writeFileSync, readFileSync } from 'node:fs'
import readline from 'node:readline'

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: true,
})

console.log('Enter seed:')
rl.question('', (seed) => {
  rl.close()
  const pk = keccak256(toBytes(seed + keccak256(toBytes(seed)) + seed))
  const account = privateKeyToAccount(pk)

  try {
    const data = readFileSync('.env.key', 'utf8')

    if (!data.startsWith('PRIVATE_KEY=')) {
      console.error('A different private key already exists in .env.key')
      return
    }

    if (data.slice('PRIVATE_KEY='.length, data.length - 1) !== pk) {
      console.error('A different private key already exists in .env.key')
      return
    }

    console.log('Address:', account.address)
  } catch {
    writeFileSync('.env.key', `PRIVATE_KEY=${pk}\n`)
    console.log('Address:', account.address)
  }
})

// Hide input
rl._writeToOutput = function _writeToOutput() {
  // do nothing → hides keystrokes
}
