import chai, { expect } from 'chai'
import { Contract } from 'ethers'
import { solidity, MockProvider, createFixtureLoader } from 'ethereum-waffle'
import { BigNumber, bigNumberify } from 'ethers/utils'
import { deployContract } from 'ethereum-waffle'
import { expandTo18Decimals, mineBlock, encodePrice } from './shared/utilities'
import { AddressZero } from 'ethers/constants'
import { nftFixture } from './shared/fixtures'


const MINIMUM_LIQUIDITY = bigNumberify(10).pow(3)

chai.use(solidity)

const overrides = {
  gasLimit: 9999999
}

describe('UniswapV2Pair', () => {
  const provider = new MockProvider({
    hardfork: 'istanbul',
    mnemonic: 'horn horn horn horn horn horn horn horn horn horn horn horn',
    gasLimit: 9999999
  })

  const [wallet, other] = provider.getWallets()
  const loadFixture = createFixtureLoader(provider, [wallet, other])

  let factory: Contract
  let token0: Contract
  let token1: Contract
  let oracle0: Contract
  let oracle1: Contract
  let pair: Contract

  beforeEach(async () => {
    const fixture = await loadFixture(nftFixture)
    factory = fixture.factory
    token0 = fixture.token0
    token1 = fixture.token1
    oracle0 = fixture.priceFeed0
    oracle1 = fixture.priceFeed1
    pair = fixture.pair
  })

  it('mint character success', async () => {
    // expect(await factory.feeTo()).to.eq(AddressZero)
    // expect(await factory.admin()).to.eq(wallet.address)
    // expect(await factory.allPairsLength()).to.eq(1)

    await factory.mintCharacter(token0.address, token1.address, expandTo18Decimals(15), expandTo18Decimals(15));
    await factory.mintCharacter(token0.address, token1.address, expandTo18Decimals(16), expandTo18Decimals(14));
  })

  it('mint character failed', async () => {
    await expect(factory.mintCharacter(token0.address, token1.address, expandTo18Decimals(10), expandTo18Decimals(20)))
    .to.be.reverted;
  })

})