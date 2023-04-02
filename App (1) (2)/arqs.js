import { ethers } from "https://cdn-cors.ethers.io/lib/ethers-5.5.4.esm.min.js";


const main = async () => {
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner()

}

main()
