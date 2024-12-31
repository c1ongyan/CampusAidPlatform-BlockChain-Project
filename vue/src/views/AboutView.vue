<template>
  <div class="about">
      <h1>我的主页</h1>
      <p v-if="account" class="account-info">当前账户: {{ account }}</p>
      <button @click="checkBalance" class="btn">查询余额</button>
      <p v-if="balance!== null" class="balance-info">当前余额: {{ balance }} 积分</p>

      <div class="purchase-section">
          <label for="amount">输入支付的以太币 (wei): </label>
          <input type="number" id="amount" v-model="purchaseAmount" min="0" class="input-field">
          <button @click="buyTokens" class="btn">购买代币</button>
      </div>
      <p v-if="purchaseMessage" class="message">{{ purchaseMessage }}</p>

      <div class="register-section">
          <template v-if="!isRegistered">
              <button @click="registerUser" class="btn">注册</button>
          </template>
          <template v-if="isRegistered">
              <p class="reputation-info">您的信誉值: {{ reputation }}</p>
          </template>
      </div>
      <p class="conversion-info">换算公式: 1 积分 = 100 wei</p>
  </div>
</template>

<script>
import { web3, campusPlat, getAccount, checkBalance, buyTokens, registerUser, getReputation } from '../api/contract';

export default {
  data() {
      return {
          balance: null,
          purchaseAmount: 0,
          purchaseMessage: '',
          account: '',
          isRegistered: false,
          reputation: 0
      };
  },
  async created() {
      try {
          this.account = await getAccount();
          this.updateBalance();
          const reputation = await this.getReputation();
          if (reputation > 0) {
              this.isRegistered = true;
              this.reputation = reputation;
          }
      } catch (error) {
          console.error(error);
          this.purchaseMessage = '无法连接到以太坊网络';
      }
  },
  methods: {
      async updateBalance() {
          try {
              this.balance = await checkBalance(this.account);
          } catch (error) {
              console.error(error);
              this.purchaseMessage = '无法获取余额';
          }
      },
      async checkBalance() {
          await this.updateBalance();
      },
      async buyTokens() {
          if (this.purchaseAmount <= 0) {
              this.purchaseMessage = '请输入有效的购买数量';
              return;
          }
          try {
              const receipt = await buyTokens(this.purchaseAmount);
              this.purchaseMessage = `成功购买 ${this.purchaseAmount} wei 的代币`;
              await this.updateBalance();
              this.purchaseAmount = 0;
          } catch (error) {
              console.error(error);
              this.purchaseMessage = '购买失败，请检查您的账户资金';
          }
      },
      async registerUser() {
          try {
              await registerUser();
              this.isRegistered = true;
              this.reputation = await this.getReputation();
          } catch (error) {
              console.error(error);
              this.purchaseMessage = '注册失败';
          }
      },
      async getReputation() {
          const account = await getAccount();
          return await campusPlat.methods.getReputation(account).call();
      }
  }
};
</script>

<style scoped>
.about {
  text-align: center;
  margin-top: 50px;
  font-family: Arial, sans-serif;
}

.btn {
  background-color: #4CAF50;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  margin: 10px;
  transition: background-color 0.3s;
}

.btn:hover {
  background-color: #45a049;
}

.input-field {
  width: 150px;
  padding: 8px;
  margin-right: 10px;
  border: 1px solid #ccc;
  border-radius: 4px;
}

.balance-info {
  margin-top: 20px;
  font-size: 1.2em;
  color: #333;
}

.message {
  margin-top: 10px;
  font-size: 1em;
  color: #555;
}

.purchase-section {
  margin-top: 20px;
}

.account-info {
  margin-bottom: 20px;
  font-size: 1.2em;
  color: #333;
}

.register-section {
  margin-top: 20px;
}

.reputation-info {
  margin-top: 10px;
  font-size: 1.2em;
  color: #333;
}

.conversion-info {
  margin-top: 20px;
  font-size: 1em;
  color: #333;
}
</style>