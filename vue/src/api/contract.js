import Web3 from 'web3';
import CampusContract  from './CampusAidPlatform.json';

const contractAddress = '0xAF6ac4F2FF356728e801715aa7D407bd22A91ed1'; // 替换为你的合约地址

//const providerUrl = 'http://127.0.0.1:7545'; // Ganache 默认的 HTTP 提供者 URL

let web3;
let campusPlat;

if (window.ethereum) {
  web3 = new Web3(window.ethereum);
  try {
    const networkId = await web3.eth.net.getId();
    const deployedNetwork = CampusContract.networks[networkId];
    if (!deployedNetwork) {
      throw new Error('Smart contract not deployed to the current network');
    }
    campusPlat = new web3.eth.Contract(CampusContract.abi, contractAddress);

    // 监听 accountsChanged 事件
    window.ethereum.on('accountsChanged', (accounts) => {
      console.log('Accounts changed:', accounts);
      if (accounts.length > 0) {
        const account = accounts[0];
        console.log('New account:', account);
        // 触发一个自定义事件来通知 Vue 组件更新账户信息
        document.dispatchEvent(new CustomEvent('accountChanged', { detail: account }));
      } else {
        console.error('No accounts found');
      }
    });

    // 请求账户访问权限
    await window.ethereum.request({ method: 'eth_requestAccounts' });
  } catch (error) {
    console.error('Error connecting to the network:', error);
  }
} else {
  console.error('Non-Ethereum browser detected. You should consider trying MetaMask!');
}

const getAccount = async () => {
  const accounts = await web3.eth.getAccounts();
  return accounts[0];
};

const checkBalance = async (account) => {
  try {
    const balance = await campusPlat.methods.balanceOf(account).call();
    return balance;
  } catch (error) {
    console.error(error);
    throw error;
  }
};

const buyTokens = async (value) => {
  const account = await getAccount();
  try {
    const receipt = await campusPlat.methods.buyTokens().send({
      from: account,
      value: Web3.utils.toWei(value.toString(10), 'wei')
    });
    return receipt;
  } catch (error) {
    console.error(error);
    throw error;
  }
};

// register 函数
const registerUser = async () => {
    const account = await getAccount();
    try {
        const receipt = await campusPlat.methods.register().send({ from: account });
        return receipt;
    } catch (error) {
        console.error(error);
        throw error;
    }
};

// publishResource 函数
const publishResource = async (title, description, price) => {
    const account = await getAccount();
    try {
        const receipt = await campusPlat.methods.publishResource(title, description, price).send({ from: account });
        return receipt;
    } catch (error) {
        console.error(error);
        throw error;
    }
};

// purchaseResource 函数
const purchaseResource = async (resourceId) => {
    const account = await getAccount();
    try {
        const receipt = await campusPlat.methods.purchaseResource(resourceId).send({ from: account });
        return receipt;
    } catch (error) {
        console.error(error);
        throw error;
    }
};

// createTask 函数
const createTask = async (title, description, points, taskType, deadline) => {
    const account = await getAccount();
    try {
        const receipt = await campusPlat.methods.createTask(title, description, points, taskType, deadline).send({ from: account });
        return receipt;
    } catch (error) {
        console.error(error);
        throw error;
    }
};

// acceptTask 函数
const acceptTask = async (taskId) => {
    const account = await getAccount();
    try {
        const receipt = await campusPlat.methods.acceptTask(taskId).send({ from: account });
        return receipt;
    } catch (error) {
        console.error(error);
        throw error;
    }
};

// completeTask 函数
const completeTask = async (taskId) => {
    const account = await getAccount();
    try {
        const receipt = await campusPlat.methods.completeTask(taskId).send({ from: account });
        return receipt;
    } catch (error) {
        console.error(error);
        throw error;
    }
};

// cancelTask 函数
const cancelTask = async (taskId) => {
    const account = await getAccount();
    try {
        const receipt = await campusPlat.methods.cancelTask(taskId).send({ from: account });
        return receipt;
    } catch (error) {
        console.error(error);
        throw error;
    }
};

// submitTaskAsDisputed 函数
const submitTaskAsDisputed = async (taskIndex, reason) => {
    const account = await getAccount();
    try {
        const receipt = await campusPlat.methods.submitTaskAsDisputed(taskIndex, reason).send({ from: account });
        return receipt;
    } catch (error) {
        console.error(error);
        throw error;
    }
};

// voteDispute 函数
const voteDispute = async (taskId, favorCreator) => {
    const account = await getAccount();
    try {
        const receipt = await campusPlat.methods.voteDispute(taskId, favorCreator).send({ from: account });
        return receipt;
    } catch (error) {
        console.error(error);
        throw error;
    }
};

// 获取单个Arbitration结构体信息
async function getOneArbitration(index) {
    const data = await campusPlat.methods.arbitrations(index).call();
    return { index,...data };
}

// 获取所有Arbitration结构体信息
async function getAllArbitrations() {
    // 假设合约有方法获取arbitrations的数量，这里暂未在合约中看到，需根据实际情况调整
    const length = 0; // await campusPlat.methods.getArbitrationCount().call();
    const result = [];
    for (let i = 0; i < length; i++) {
        result.push(await getOneArbitration(i));
    }
    return result;
}

// 获取单个Task结构体信息
async function getOneTask(index) {
    const data = await campusPlat.methods.tasks(index).call();
    return { index, ...data };
}

// 获取所有Task结构体信息
async function getAllTasks() {
    const length = await campusPlat.methods.getTaskCount().call(); // 使用新添加的方法
    const result = [];
    for (let i = 0; i < length; i++) {
        result.push(await getOneTask(i));
    }
    return result;
}



// 获取单个Resource结构体信息
async function getOneResource(index) {
    const data = await campusPlat.methods.resources(index).call();
    return { index,...data };
}

// 获取所有Resource结构体信息
async function getAllResources() {
    const length = await campusPlat.methods.getResourceCount().call();
    const result = [];
    for (let i = 0; i < length; i++) {
        result.push(await getOneResource(i));
    }
    return result;
}


export {
    web3,
    campusPlat,
    getAccount,
    checkBalance,
    buyTokens,
    registerUser,
    publishResource,
    purchaseResource,
    createTask,
    acceptTask,
    completeTask,
    cancelTask,
    submitTaskAsDisputed,
    voteDispute,
    getOneArbitration,
    getAllArbitrations,
    getOneTask,
    getAllTasks,
    getOneResource,
    getAllResources
};