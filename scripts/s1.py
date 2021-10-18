from brownie import *
import os
from dotenv import load_dotenv; load_dotenv(".env")

sushiSwapRouter = "0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F"
mim3crv = "0x5a6A4D54456819380173272A5E8E9B9904BdF41B"
weth = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
dai = "0x6B175474E89094C44Da98b954EedeAC495271d0F"
private_key = os.environ.get("private_key")
INF = pow(2, 255)

a1 = accounts.add(private_key)

def __buy_mim3Crv():
  a1.transfer(to=weth, amount=10*pow(10,18), data="0xd0e30db0")
  print("WETH: ", interface.IERC20(weth).balanceOf(a1))
  interface.IERC20(weth).approve(sushiSwapRouter, INF, {'from': a1})
  interface.ISushiSwapRouter(sushiSwapRouter).swapExactTokensForTokens(10000000000000000000,
                                                                        1,
                                                                        [weth, dai],
                                                                        a1,
                                                                        32528645726,
                                                                        {'from': a1})
  print("DAI: ", interface.IERC20(dai).balanceOf(a1))
  bal = hex(interface.IERC20(dai).balanceOf(a1))
  bal = bal[2:]
  hBal = '0' * (64-len(bal)) + bal
  interface.IERC20(dai).approve("0xa79828df1850e8a3a3064576f380d90aecdd3359", INF, {'from': a1})
  a1.transfer(to="0xa79828df1850e8a3a3064576f380d90aecdd3359", 
              amount=0, 
              data="0x384e03db" +
                    "0000000000000000000000005a6a4d54456819380173272a5e8e9b9904bdf41b" +
                    "0000000000000000000000000000000000000000000000000000000000000000" +
                    hBal + 
                    "0000000000000000000000000000000000000000000000000000000000000000" +
                    "0000000000000000000000000000000000000000000000000000000000000000" +
                    "000000000000000000000000000000000000000000000620135a685afc63c65f"
              )
  print("MIM3CRV: ", interface.IERC20(mim3crv).balanceOf(a1))

def get_balances():
  print("WETH: ", interface.IERC20(weth).balanceOf(a1))
  print("ETH: ", a1.balance())
  print("DAI: ", interface.IERC20(dai).balanceOf(a1))
  print("MIM3CRV: ", interface.IERC20(mim3crv).balanceOf(a1))

def mimBalance(address):
  bal = interface.IERC20(mim3crv).balanceOf(address)
  return bal

def __main():
  hc = HarvestConvexMIM.deploy({'from': a1})
  interface.IERC20(mim3crv).approve(hc, INF, {'from': a1})
  mimBalance = interface.IERC20(mim3crv).balanceOf(a1)

  return (a1, hc, mimBalance)

def load():
  return a1, HarvestConvexMIM.at(os.environ.get("hc_contract"))

def deposit(hc):
  hc.deposit({'from': a1})

def withdraw(hc):
  hc.withdraw({'from': a1})

def checkRewards(hc):
  spellr = interface.IRewards("0x69a92f1656cd2e193797546cFe2EaF32EACcf6f7").earned(hc)
  crvr = interface.IRewards("0xFd5AbF66b003881b88567EB9Ed9c651F14Dc4771").earned(hc)
  print("{s} SPELL, {c} CRV".format(s=spellr * pow(10,-18), c=crvr * pow(10,-18)))