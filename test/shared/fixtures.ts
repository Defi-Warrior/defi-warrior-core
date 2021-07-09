import { Contract, Wallet } from 'ethers'
import { Web3Provider } from 'ethers/providers'
import { deployContract } from 'ethereum-waffle'

import { expandTo18Decimals } from './utilities'

import ERC20 from '../../build/ERC20.json'
import UniswapV2Factory from '../../build/UniswapV2Factory.json'
import UniswapV2Pair from '../../build/UniswapV2Pair.json'
import NFTWarriror from '../../build/NFTWarrior.json'
import PriceFeed from '../../build/PriceFeed.json'


interface FactoryFixture {
  factory: Contract
}

const overrides = {
  gasLimit: 9999999
}

export async function factoryFixture(_: Web3Provider, [wallet]: Wallet[]): Promise<FactoryFixture> {
  const factory = await deployContract(wallet, UniswapV2Factory, [wallet.address, "0x0"], overrides)
  return { factory }
}

interface PairFixture extends FactoryFixture {
  token0: Contract
  token1: Contract
  pair: Contract
}

interface NFTFixture extends PairFixture {
  nftWarrior: Contract,
  priceFeed0: Contract,
  priceFeed1: Contract
}

export async function pairFixture(provider: Web3Provider, [wallet]: Wallet[]): Promise<PairFixture> {
  const { factory } = await factoryFixture(provider, [wallet])

  const tokenA = await deployContract(wallet, ERC20, [expandTo18Decimals(10000)], overrides)
  const tokenB = await deployContract(wallet, ERC20, [expandTo18Decimals(10000)], overrides)

  await factory.createPair(tokenA.address, tokenB.address, overrides)
  const pairAddress = await factory.getPair(tokenA.address, tokenB.address)
  const pair = new Contract(pairAddress, JSON.stringify(UniswapV2Pair.abi), provider).connect(wallet)

  const token0Address = (await pair.token0()).address
  const token0 = tokenA.address === token0Address ? tokenA : tokenB
  const token1 = tokenA.address === token0Address ? tokenB : tokenA

  return { factory, token0, token1, pair }
}

export async function nftFixture(provider: Web3Provider, [wallet, other]: Wallet[]): Promise<NFTFixture> {
  const nftWarrior = await deployContract(wallet, NFTWarriror, ["Defi Warrior", "FIWA"], overrides);
  const factory = await deployContract(wallet, UniswapV2Factory, [wallet.address, nftWarrior.address], overrides)
  await nftWarrior.transferOwnership(factory.address);

  const priceFeed0 = await deployContract(wallet, PriceFeed, ["BTC-USDT"], overrides)
  const priceFeed1 = await deployContract(wallet, PriceFeed, ["FIWA-USDT"], overrides)

  const tokenA = await deployContract(wallet, ERC20, [expandTo18Decimals(10000)], overrides)
  const tokenB = await deployContract(wallet, ERC20, [expandTo18Decimals(10000)], overrides)

  await factory.createPair(tokenA.address, tokenB.address, priceFeed0.address, priceFeed1.address, overrides)
  const pairAddress = await factory.getPair(tokenA.address, tokenB.address)
  const pair = new Contract(pairAddress, JSON.stringify(UniswapV2Pair.abi), provider).connect(wallet)

  const token0Address = (await pair.token0()).address
  const token0 = tokenA.address === token0Address ? tokenA : tokenB
  const token1 = tokenA.address === token0Address ? tokenB : tokenA

  await token0.transfer(other.address, expandTo18Decimals(100))
  await token1.transfer(other.address, expandTo18Decimals(100))

  await token0.approve(factory.address, expandTo18Decimals(100))
  await token1.approve(factory.address, expandTo18Decimals(100))


  return { factory, token0, token1, pair, nftWarrior, priceFeed0, priceFeed1 }
}