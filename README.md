# XRouter and XCloud plugin samples

These scripts and configs provide sample XCloud plugins for use by Blocknet (and Scalaris) servicenodes. They are rudimentary demonstrators designed as templates or building blocks which can be adapted and customised by servicenode operators. They are really not hardened for production use.

Providing XRouter and XCloud services does require some technical understanding and competence. Essential skills include 
- be able to google stuff, 
- use the linux command line, 
- follow instructions, 
- think for yourself.  

For background information refer to the [servicenode documentation](https://docs.blocknet.co/service-nodes/introduction/) and in particular the [XRouter](https://docs.blocknet.co/service-nodes/xrouter-configuration/) and [XCloud](https://docs.blocknet.co/service-nodes/xcloud-configuration/) sections.

XCloud plugins may be of two types: RPC and Docker. There are examples here of both types.

## RPC plugins
RPC plugins make RPC calls to a daemon (most likely) running on the same server as the servicenode. The target daemon deos not have to be for a coin supported by XBridge. Hence these examples include RPCs for Crown (CRW), Merge (MERGE) and Alqo (XLQ) which are not (currently) supported by XBridge and not tradeable on BlockDX.

| Plugin | Description |
| ----------- | ----------- |
| block_blockchaininfo | Execute BLOCK getblockchaininfo |
| btc_blockchaininfo | Execute BTC getblockchaininfo |
| crw_blockchaininfo | Execute CRW getblockchaininfo |
| crw_mempoolinfo | Execute CRW getmempoolinfo |
| crw_mnlist | Execute CRW masternodelist |
| crw_peerinfo | Execute CRW getpeerinfo |
| crw_snlist | Execute CRW systemnodelist |
| crw_txoutsetinfo | Execute CRW gettxoutsetinfo |
| dash_blockchaininfo | Execute DASH getblockchaininfo |
| dgb_blockchaininfo | Execute DGB getblockchaininfo |
| doge_blockchaininfo | Execute DOGE getblockchaininfo |
| ltc_blockchaininfo | Execute LTC getblockchaininfo |
| merge_mempoolinfo | Execute MERGE getmempoolinfo |
| merge_mncount | Execute MERGE getmasternodecount |
| merge_mnlist | Execute MERGE listmasternodes |
| merge_peerinfo | Execute MERGE getpeerinfo |
| rvn_blockchaininfo | Execute RVN getblockchaininfo |
| scc_blockchaininfo | Execute SCC getblockchaininfo |
| sys_blockchaininfo | Execute SYS getblockchaininfo |
| xlq_mempoolinfo | Execute XLQ getmempoolinfo |
| xlq_mncount | Execute XLQ getmasternodecount |
| xlq_mnlist | Execute XLQ listmasternodes |
| xlq_peerinfo | Execute XLQ getpeerinfo |



RPC plugins offer only very limited functionality and no possibility of "massaging" the results within the plugin. Any massaging required must be performed at the client side after receiving the RPC result. For example, the getblockchaininfo calls here all provide access to the relevant blockchain size on disk but it is embedded in a bunch of other information. In lieu of an actual xxx_sizeondisk service a client can instead

```
blocknet-cli xrService btc_blockchaininfo | grep size_on_disk
```
which still needs a little bit of post-processing. Alternatively, if jq is installed the client can
```
blocknet-cli xrService btc_blockchaininfo|jq -r .reply | jq .size_on_disk
```

## Docker plugins
Docker-type plugins can be much more functional than RPC ones but are more complicated to create, deploy and configure. These examples are all very simple wrappers around well-known 3rd-party APIs. 

| Plugin | Description |
| ----------- | ----------- |
| AlexaRank | Find the Alexa page rank for a URL |
| cgprice | Get the current CoinGecko price for a coin or token |
| cgpricej | Get extended current CoinGecko price information for a coin or token |
| indexer | Run pre-packaged sample queries against the Blocknet/Avalanche indexer |
| weather | Get the current weather information for a given location |
| yfprice | Get the current price for a Yahoo! Finance asset |
| yfticker | Get the current ticker for a Yahoo! Finance asset |


The wrappers can be written in any language you're comfortable with. They can be made as generic or as specific as you want and are competent to code. These examples use bash or Python.

Most APIs like those used here require registration and use of an API key. They generally perform rate-limiting and provide different feature sets depending on how much you want to pay for a subscription. 

Plugins don't have to call external APIs; they can get data from *any* source, such as local hardware (eg: weather station, TNC, true random number generator, IoT appliance), local database, ... 

## Deployment

### prerequisites
1. Install Docker if not already installed. You will have already done this if yours is an EXR servicenode. If not, there are hundreds of examples showing how to do so on the internet. Your servicenode hosting provider may have customised instructions which best suit your setup. Digital Ocean provide a number of good tutorials which are widely applicable, for example https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04
2. Install Python >= 3.6 if not already installed and you want to be able to tinker with/test the plugins outside of a Docker container. Using your distro's package manager will be the easiest way to install Python3 but you might get an old version this way. Use your favourite search engine to find the best instructions for your particular environment.   

### using tarfile

1. Download the [archive](https://github.com/walkjivefly/xcloud-plugins/archive/refs/tags/v1.0.tar.gz) to your servicenode plugins directory, eg:
   ```
   cd ~/.blocknet/plugins
   wget https://github.com/walkjivefly/xcloud-plugins/archive/refs/tags/v1.0.tar.gz
   tar -xvf xcloudsample
   ```
2. Customise the API keys in individual plugins. These plugins require a personal API key:
   | Plugin | API key available from |
   | ----------- | ----------- |
   | AlexaRank | https://aws.amazon.com/marketplace/pp/prodview-w6qmxismbbs7u?ref_=srh_res_product_title |
   | weather | https://openweathermap.org/appid |
3. The cgprice, cgpricej, yfprice and yfticker plugins don't (currently) require a personal API key.
4. Customise the target address in the indexer plugin. This demonstrates that the actual service may be provided by some machine other than the servicenode host itself.
5. Install the xcloudsample Docker image. This comprises a minimal Ubuntu image with curl and just enough Python3 to run the examples[^1] but it does not include the actual plugin scripts.
   ```
   docker pull walkjivefly:xcloudsample
   ```
   Check what the previous command did and make a note of the image id
   ```
   docker images
   ```
   The result will be something like
   ```
   REPOSITORY                 TAG       IMAGE ID       CREATED        SIZE
   walkjivefly/xcloudsample   latest    baaf7fd4c851   16 hours ago   630MB
   ```
6. Create an actual container from the image and leave it running in the background.
   ```
   docker run -it -d --name xcloudshell baaf7fd4c851 bash
   ```
7. Copy the plugin scripts to the container
   ```
   docker cp AlexaRank xcloudshell:/usr/local/bin
   docker cp cgprice xcloudshell:/usr/local/bin
   docker cp cgpricej xcloudshell:/usr/local/bin
   docker cp indexer xcloudshell:/usr/local/bin
   docker cp weather xcloudshell:/usr/local/bin
   docker cp yfprice xcloudshell:/usr/local/bin
   docker cp yfticker xcloudshell:/usr/local/bin
   ```
8. Check they're really there by
   ```
   docker exec xcloudshell ls -l /usr/local/bin
   ```
   The output should be something like
   ```
   total 48
   -rwxr-xr-x 1 1000 1000  278 Jun 19 10:43 AlexaRank
   -rwxr-xr-x 1 1000 1000 2569 Jun 19 11:24 cgprice
   -rwxr-xr-x 1 1000 1000 2787 Jun 19 11:24 cgpricej
   -rwxr-xr-x 1 root root  225 Jun 18 20:22 chardetect
   -rwxr-xr-x 1 root root  220 Jun 18 20:22 f2py
   -rwxr-xr-x 1 root root  220 Jun 18 20:22 f2py3
   -rwxr-xr-x 1 root root  220 Jun 18 20:22 f2py3.6
   -rwxr-xr-x 1 1000 1000  671 Jun 19 11:24 indexer
   -rwxr-xr-x 1 root root  209 Jun 18 20:22 sample
   -rwxr-xr-x 1 1000 1000  133 Jun 19 11:24 weather
   -rwxr-xr-x 1 1000 1000 1717 Jun 19 11:24 yfprice
   -rwxr-xr-x 1 1000 1000 1711 Jun 19 11:24 yfticker
   ```
   and that they do what they're supposed to, for example by
   ```
   docker exec xcloudshell AlexaRank bbc.co.uk
   docker exec xcloudshell cgprice btc eur
   docker exec xcloudshell indexer pairs
   docker exec xcloudshell weather kathmandu
   docker exec xcloudshell yfprice GBPUSD=X
   docker exec xcloudshell yfticker ORCL
   ``` 
   
9.  Commit the changes to the image so if anything destructive happens to the container you can recreate it without having to copy the plugins in again. 
   ```
   docker commit -m "Populated and ready to use" xcloudshell
   ``` 
11. Add chosen plugins to your ```xrouter.conf```. Plugins can inherit the default ```[main]``` settings or you can customise them on a per-plugin basis. For example, add the following line to enable all of the example plugins
   ```
   plugins=AlexaRank,cgprice,cgpricej,cgtest,indexer,yfprice,weather,yfticker,btc_blockchaininfo,block_blockchaininfo,dash_blockchaininfo,dgb_blockchaininfo,doge_blockchaininfo,ltc_blockchaininfo,rvn_blockchaininfo,scc_blockchaininfo,sys_blockchaininfo,xvg_blockchaininfo,crw_mnlist,crw_snlist,crw_txoutsetinfo,crw_blockchaininfo,crw_mempoolinfo,crw_peerinfo,xlq_mncount,xlq_mnlist,xlq_mempoolinfo,xlq_peerinfo,merge_mncount,merge_mnlist,merge_mempoolinfo,merge_peerinfo
   ```
   Unless you are running DASH, DOGE, LTC, RVN, SCC, SYS, XVG, CRW, XLQ and MERGE you will need to choose only the plugins your servicenode can support. This is also your opportunity to extend the functionality of the XRouter network by creating xxx_blockchaininfo plugins for other coins accessible from your servicenode, or to create additional RPC plugins for other commands you think may be useful.

11. Reload the XRouter config and check that the new services are listed in the servicenode status, for example
    ```
    blocknet-cli xrReloadConfigs
    true
    {
      "alias": "SN01",
      "tier": "SPV",
      "snodekey":  "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "address": "Bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "timelastseen": 1624024544,
      "timelastseenstr": "2021-06-18T13:55:44.000Z",
      "status": "running",
      "services": [
        "BLOCK",
        ...
        "xrs::AlexaRank",
        "xrs::block_blockchaininfo",
        "xrs::btc_blockchaininfo",
        "xrs::cgprice",
        "xrs::cgpricej",
        "xrs::crw_blockchaininfo",
        "xrs::crw_mempoolinfo",
        "xrs::crw_mnlist",
        "xrs::crw_peerinfo",
        "xrs::crw_snlist",
        "xrs::crw_txoutsetinfo",
        "xrs::dash_blockchaininfo",
        "xrs::dgb_blockchaininfo",
        "xrs::doge_blockchaininfo",
        "xrs::indexer",
        "xrs::ltc_blockchaininfo",
        "xrs::merge_mempoolinfo",
        "xrs::merge_mncount",
        "xrs::merge_mnlist",
        "xrs::merge_peerinfo",
        "xrs::rvn_blockchaininfo",
        "xrs::scc_blockchaininfo",
        "xrs::sys_blockchaininfo",
        "xrs::weather",
        "xrs::xlq_mempoolinfo",
        "xrs::xlq_mncount",
        "xrs::xlq_mnlist",
        "xrs::xlq_peerinfo",
        "xrs::xvg_blockchaininfo",
        "xrs::yfprice",
        "xrs::yfticker"
       ]
    }
    ```
12. Tell the world what you've done! 

[^1]: For security reasons you may prefer to build your own container using the Dockerfile found in the archive. This and the requirements.txt were used to create the xcloudsample image. 