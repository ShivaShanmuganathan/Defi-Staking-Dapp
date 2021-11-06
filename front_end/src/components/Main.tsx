import { useEthers } from '@usedapp/core'
import { Button } from '@mui/material';
import { YourWallet } from './yourWallet/YourWallet';
import networkMapping from "../chain-info/map.json"
import { constants } from 'ethers';
import brownieConfig from "../brownie-config-json.json"
import helperConfig from "../helper-config.json"


export type Token = {
    address: string
    name: string
}

export const Main = () => {
    
    const { chainId } = useEthers()
    const networkName = chainId ? helperConfig[chainId] : "ganache"
    const dappTokenAddress = chainId ? networkMapping[String(chainId)]["DappToken"][0] : constants.AddressZero
    
    const wethTokenAddress = chainId ? brownieConfig["networks"][networkName]["weth_token"] : constants.AddressZero
    // At TOP, show Wallet Balance, and STAKE Button
    // At BOTTOM, show STAKED Balance, and UNSTAKE Button

    const supportedTokens: Array<Token> = [
        {
            address: wethTokenAddress,
            name: "WETH"
        },
        {
            address: dappTokenAddress,
            name: "DAPP"
        }
    ]

    
    return (
        
        <div>
            <YourWallet supportedTokens={supportedTokens} />
        </div>
    )
}