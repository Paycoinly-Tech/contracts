cd ..

forge clean
forge build

npx @openzeppelin/upgrades-core validate
