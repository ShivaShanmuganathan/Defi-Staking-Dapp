import { useEthers } from '@usedapp/core'
import { Button } from '@mui/material';
export const Header = () => {
    
    const {account, activateBrowserWallet} = useEthers();
    
        // figure out if we are connected or not
        // if not connected, show CONNECT button
        // otherwise, just show the button or something
    
    const isConnected = account !== undefined
    return (
        
        <div>
            {
                isConnected ?
                <Button
                    color="primary" variant="contained" >
                    CONNECTED!
                </Button> :
                <Button 
                    color="primary" variant="contained" 
                    onClick={() => activateBrowserWallet()}>
                        
                    CONNECT WALLET
                </Button>

                
            }
        </div>
    )
}