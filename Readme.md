## CampusAidPlatform-BlockChain-Project

（前端+js小白，纯大模型带搓，界面功能冗余不够美观，只是基础的实现）

#### 项目介绍：

基于区块链的校园互助平台项目

Vue2+web3.js+truffle+Ganache+MetaMask



#### 项目创建步骤：

1.创建vue框架

```
vue create vue
```

2.创建truffle空模板

```
truffle init
```

3.创建合约，迁移文件，修改truffle-config.js文件

3.1因为该合约超过的以太坊对合约的大小限制，将optimizer: enabled设置为true开启优化，且必须指定这块的设置，不然truffle migrate迁移时报错合约中有无效`hit an invalid opcode while deploying`错误，参考[该篇博客](https://blog.csdn.net/qq_41146650/article/details/137090765)

```js
  compilers: {
    solc: {
      version: "0.8.21",      // Fetch exact version from solc-bin (default: truffle's version)
      docker: false,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
         enabled: true,
         runs: 200
       },
       evmVersion: "byzantium"
      }
    }
  },
```

3.2配置网络 因为是使用默认的Ganache GUI工具提供测试网络，其默认网络地址为`HTTP://127.0.0.1:7545`

```js
    development: {
     host: "127.0.0.1",     // Localhost (default: none)
     port: 7545,            // Standard Ethereum port (default: none)
     network_id: "*",       // Any network (default: none)
    },
```

4.添加依赖

对合约文件添加依赖

```shell
yarn add @openzeppelin/contracts -S
```

对vue文件添加依赖

```
yarn add web3 -s
```

5.开启Ganache，选择快速开启即可，右上角设置添加workspace对应的config文件，这样能在Ganache中清晰看到该配置文件部署的合约地址的信息

![image-20241231145945815](https://testingcf.jsdelivr.net/gh/c1ongyan/picture@main/img/202412311459943.png)

6.编译合约，部署合约

```
truffle compile
truffle migrate
```

将编译后的build/contract文件夹下的合约对应的json文件放入vue/src/api下，合约abi从该文件获得

7.编写js代码与合约交互，编写前端代码

8.启动服务 

在vue文件下运行，启动服务

```
yarn serve
```

9.在小狐狸中添加测试网络以及账户



#### 效果展示

主页





![image-20241231151006209](https://testingcf.jsdelivr.net/gh/c1ongyan/picture@main/img/202412311510254.png)

我的任务与资源

![image-20241231151134051](https://testingcf.jsdelivr.net/gh/c1ongyan/picture@main/img/202412311511107.png)

待仲裁任务

![image-20241231151150414](https://testingcf.jsdelivr.net/gh/c1ongyan/picture@main/img/202412311511456.png)

所有资源

![image-20241231151159994](https://testingcf.jsdelivr.net/gh/c1ongyan/picture@main/img/202412311512067.png)

所有任务

![image-20241231151208203](https://testingcf.jsdelivr.net/gh/c1ongyan/picture@main/img/202412311512340.png)