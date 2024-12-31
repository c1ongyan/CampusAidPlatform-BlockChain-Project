<template>
    <div class="resources">
      <h1>所有资源</h1>
      <div v-for="resource in resources" :key="resource.id" class="resource-card">
        <div class="resource-header">
          <h2>{{ resource.title }}</h2>
          <p>价格: {{ resource.price }}</p>
          <button @click="showDetails(resource)" class="btn">详情</button>
          <button v-if="resource.owner!== currentAccount" @click="purchaseResource(resource.id)" class="btn purchase-btn">购买资源</button>
        </div>
        <div v-if="selectedResource && selectedResource.id === resource.id" class="resource-details">
          <h3>详细信息</h3>
          <p><strong>描述:</strong> {{ resource.description }}</p>
          <p><strong>发布者:</strong> {{ resource.owner }}</p>
        </div>
      </div>
      <div class="create-resource-section">
        <h2>发布新资源</h2>
        <label for="title">资源标题：</label>
        <input type="text" id="title" v-model="newResource.title" required>
        <label for="description">资源描述：</label>
        <textarea id="description" v-model="newResource.description" required></textarea>
        <label for="price">资源价格：</label>
        <input type="number" id="price" v-model="newResource.price" required>
        <button @click="createResource" class="btn">发布资源</button>
      </div>
    </div>
  </template>
  
  <script>
  import { getAllResources, publishResource, purchaseResource, getAccount } from '../api/contract';
  export default {
    data() {
      return {
        resources: [],
        selectedResource: null,
        newResource: {
          title: '',
          description: '',
          price: 0
        },
        currentAccount: ''
      };
    },
    async created() {
      try {
        const resources = await getAllResources();
        this.resources = resources.map(resource => {
          return {
          ...resource,
            price: parseFloat(resource.price)
          };
        });
        this.currentAccount = await getAccount();
      } catch (error) {
        console.error('获取资源失败', error);
      }
    },
    methods: {
      showDetails(resource) {
        if (this.selectedResource && this.selectedResource.id === resource.id) {
          this.selectedResource = null;
        } else {
          this.selectedResource = resource;
        }
      },
      async createResource() {
        try {
          await publishResource(
            this.newResource.title,
            this.newResource.description,
            this.newResource.price
          );
          // 发布资源成功后，清空表单并更新资源列表
          this.newResource = {
            title: '',
            description: '',
            price: 0
          };
          const resources = await getAllResources();
          this.resources = resources.map(resource => {
            return {
          ...resource,
              price: parseFloat(resource.price)
            };
          });
        } catch (error) {
          console.error('发布资源失败', error);
        }
      },
      async purchaseResource(resourceId) {
        try {
          await purchaseResource(resourceId);
          // 购买资源成功后，更新资源列表（这里简单地重新获取所有资源，可根据实际情况优化）
          const resources = await getAllResources();
          this.resources = resources.map(resource => {
            return {
          ...resource,
              price: parseFloat(resource.price)
            };
          });
        } catch (error) {
          console.error('购买资源失败', error);
        }
      }
    }
  };
  </script>
  
  <style scoped>
  .resources {
    text-align: center;
    margin-top: 50px;
    font-family: Arial, sans-serif;
  }
  
  .resource-card {
    border: 1px solid #ccc;
    border-radius: 5px;
    padding: 15px;
    margin: 20px auto;
    width: 80%;
    max-width: 600px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }
  
  .resource-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .resource-header h2 {
    margin: 0;
  }
  
  .resource-header p {
    margin: 0;
    font-size: 1em;
    color: #555;
  }
  
  .resource-details {
    margin-top: 20px;
    text-align: left;
  }
  
  .resource-details h3 {
    margin-top: 0;
  }
  
  .resource-details p {
    margin: 5px 0;
    font-size: 1em;
    color: #333;
  }
  
  .btn {
    background-color: #4CAF50;
    color: white;
    padding: 10px 20px;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    transition: background-color 0.3s;
  }
  
  .btn:hover {
    background-color: #45a049;
  }
  
  .purchase-btn {
    background-color: #007BFF;
  }
  
  .purchase-btn:hover {
    background-color: #0056b3;
  }
  
  .create-resource-section {
    margin-top: 30px;
    border: 1px solid #ccc;
    border-radius: 5px;
    padding: 20px;
    width: 80%;
    max-width: 600px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    margin: 0 auto;
}

.create-resource-section label {
    display: block;
    margin-bottom: 10px;
    font-size: 1em;
    color: #333;
    text-align: left;
    width: 100%;
}

.create-resource-section input[type="text"],
.create-resource-section textarea,
.create-resource-section input[type="number"] {
    width: 100%;
    padding: 10px;
    margin-bottom: 20px;
    border: 1px solid #ccc;
    border-radius: 4px;
    font-size: 1em;
}
  </style>