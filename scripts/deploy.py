import os
from dotenv import load_dotenv; load_dotenv(".env")
from brownie import HarvestConvexMIM, accounts

def main():
  acct = accounts.load(os.environ.get("id"))
  print(acct)
  tx = HarvestConvexMIM.deploy({'from': acct})
  print(tx)