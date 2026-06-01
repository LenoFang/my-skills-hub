---
name: frontend-vue-rules
description: "Use when 编写或修改 Vue 2 前端代码、front-pc 页面、iView/View Design 组件，或用户提到 '组件结构'、'API 调用'、'表格 / 表单 / 弹窗 / 分页模式'、'Vuex'、'EventBus'、'权限按钮'、'生命周期'。"
---
# 前端 Vue 开发规范

## R-FE-001 Vue 组件结构
按 template → script → style 顺序，style 使用 `scoped`
```vue
<template>
  <!-- 页面内容 -->
</template>

<script>
export default {
  name: 'ComponentName',
  data() {
    return {}
  },
  computed: {},
  created() {},
  mounted() {},
  methods: {}
}
</script>

<style lang="less" scoped>
</style>
```

## R-FE-002 API 调用封装
API 统一放在 `src/api/` 目录，使用 `axios.request()`
```javascript
import axios from '@/libs/api.request'

export function getData(params) {
  return axios.request({
    url: '/xxx/list',
    method: 'get',
    params
  })
}

export function saveData(data) {
  return axios.request({
    url: '/xxx/save',
    method: 'post',
    data
  })
}
```

## R-FE-003 API 响应处理
`code === 0` 表示成功，否则提示错误
```javascript
const res = await getData()
if (!res.code) {
  this.tableData = res.data
} else {
  this.$Message.error(res.msg)
}
```

## R-FE-004 表格列定义规范
- 列定义放在 `data` 的 `tableColumns`
- 使用 `minWidth` 代替固定 `width`
- 序号使用 `params.row._index + 1`
```javascript
tableColumns: [
  {
    title: '序号',
    width: 80,
    render: (h, params) => h('span', params.row._index + 1)
  },
  {
    title: '名称',
    key: 'name',
    minWidth: 120
  },
  {
    title: '操作',
    width: 150,
    render: (h, params) => {
      return h('div', [
        h('Button', {
          props: { type: 'primary', size: 'small' },
          on: { click: () => this.handleEdit(params.row) }
        }, '编辑'),
        h('Button', {
          props: { type: 'error', size: 'small' },
          style: { marginLeft: '8px' },
          on: { click: () => this.handleDelete(params.row) }
        }, '删除')
      ])
    }
  }
]
```

## R-FE-005 Table 展开行渲染
`type: 'expand'` 必须通过 `render` 函数渲染，不能用 template slot
```javascript
{
  type: 'expand',
  width: 50,
  render: (h, params) => {
    return h('div', { style: { padding: '10px' } }, [
      h('Button', { props: { type: 'primary', size: 'small' } }, '操作'),
      h('Table', {
        props: {
          columns: this.subColumns,
          data: params.row.subList,
          size: 'small'
        }
      })
    ])
  }
}
```

## R-FE-006 动态列定义
需要在 render 中使用 `this` 的列，在 `created` 钩子中初始化
```javascript
created() {
  this.initColumns()
},
methods: {
  initColumns() {
    this.tableColumns = [
      {
        title: '操作',
        render: (h, params) => {
          return h('Button', {
            on: { click: () => this.handleClick(params.row) }
          }, '点击')
        }
      }
    ]
  }
}
```

## R-FE-007 表格加载状态
使用 `tableLoading` 控制加载状态
```javascript
async loadData() {
  this.tableLoading = true
  try {
    const res = await getData(this.searchForm)
    if (!res.code) {
      this.tableData = res.data.list || res.data
      this.pagination.total = res.data.total || 0
    } else {
      this.$Message.error(res.msg)
    }
  } catch (e) {
    console.error(e)
  } finally {
    this.tableLoading = false
  }
}
```

## R-FE-008 表单验证规则
验证规则定义在 `formRules`，`prop` 与字段名一致
```javascript
formRules: {
  name: [
    { required: true, message: '请输入名称', trigger: 'blur' }
  ],
  type: [
    { required: true, type: 'number', message: '请选择类型', trigger: 'change' }
  ],
  customField: [
    {
      required: true,
      validator: (rule, value, callback) => {
        if (!value) {
          callback(new Error('请输入'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ]
}
```

## R-FE-009 表单提交规范
提交前验证，使用 `saving` 防止重复提交
```javascript
async handleSave() {
  this.$refs.form.validate(async (valid) => {
    if (!valid) return
    this.saving = true
    try {
      const res = await saveData(this.formData)
      if (!res.code) {
        this.$Message.success('保存成功')
        this.showModal = false
        this.loadData()
      } else {
        this.$Message.error(res.msg)
      }
    } catch (e) {
      console.error(e)
      this.$Message.error('保存失败')
    } finally {
      this.saving = false
    }
  })
}
```

## R-FE-010 弹窗控制规范
- 使用 `v-model` 控制显示
- 设置 `mask-closable="false"`
- 新增/编辑共用时用 `modalTitle` 区分
```vue
<Modal
  v-model="showModal"
  :title="modalTitle"
  :mask-closable="false"
  width="600"
>
  <Form ref="form" :model="formData" :rules="formRules">
    <!-- 表单内容 -->
  </Form>
  <div slot="footer">
    <Button @click="showModal = false">取消</Button>
    <Button type="primary" :loading="saving" @click="handleSave">保存</Button>
  </div>
</Modal>
```

## R-FE-011 编辑数据拷贝
编辑时必须深拷贝，避免直接修改原数据
```javascript
handleAdd() {
  this.modalTitle = '新增'
  this.formData = { name: '', type: null }
  this.showModal = true
}

handleEdit(row) {
  this.modalTitle = '编辑'
  this.formData = { ...row }  // 浅拷贝
  // 或 JSON.parse(JSON.stringify(row))  // 深拷贝
  this.showModal = true
}
```

## R-FE-012 删除确认规范
删除操作必须弹出确认框
```javascript
handleDelete(row) {
  this.$Modal.confirm({
    title: '删除确认',
    content: `确定要删除"${row.name}"吗？`,
    onOk: async () => {
      try {
        const res = await deleteData(row.id)
        if (!res.code) {
          this.$Message.success('删除成功')
          this.loadData()
        } else {
          this.$Message.error(res.msg)
        }
      } catch (e) {
        this.$Message.error('删除失败')
      }
    }
  })
}
```

## R-FE-013 分页组件使用
```vue
<Page
  :total="pagination.total"
  :current="pagination.current"
  :page-size="pagination.pageSize"
  show-total
  show-sizer
  @on-change="handlePageChange"
  @on-page-size-change="handlePageSizeChange"
/>
```
```javascript
data() {
  return {
    pagination: {
      current: 1,
      pageSize: 10,
      total: 0
    }
  }
},
methods: {
  handlePageChange(page) {
    this.pagination.current = page
    this.loadData()
  },
  handlePageSizeChange(size) {
    this.pagination.pageSize = size
    this.pagination.current = 1
    this.loadData()
  }
}
```

## R-FE-014 Vuex 状态访问
使用 `mapState` 简化访问
```javascript
import { mapState, mapMutations } from 'vuex'

export default {
  computed: {
    ...mapState(['user', 'pageMenuList'])
  },
  methods: {
    ...mapMutations(['setUser'])
  }
}
```

## R-FE-015 Event Bus 使用
跨组件通信使用 Event Bus，必须在 `beforeDestroy` 中移除监听
```javascript
import bus from '@/utils/bus'

mounted() {
  bus.$on('event-name', this.handleEvent)
},
beforeDestroy() {
  bus.$off('event-name')
},
methods: {
  handleEvent(data) { },
  emitEvent() {
    bus.$emit('event-name', data)
  }
}
```

## R-FE-016 Select 远程搜索
```vue
<Select
  v-model="selectedValue"
  filterable
  remote
  :remote-method="searchMethod"
  :loading="searchLoading"
  placeholder="输入关键字搜索"
  transfer
>
  <Option v-for="item in searchList" :key="item.id" :value="item.id">
    {{ item.name }}
  </Option>
</Select>
```

## R-FE-017 生命周期使用规范
- `created`：数据初始化、API调用、路由参数读取（不依赖DOM）
- `mounted`：DOM操作、第三方库初始化
- `beforeDestroy`：清理定时器、取消订阅、移除事件监听
```javascript
created() {
  this.id = this.$route.query.id || '';
  this.init();
  this.loadData();
},
mounted() {
  // DOM相关初始化
},
beforeDestroy() {
  if (this.timer) {
    clearTimeout(this.timer);
  }
  bus.$off('event-name');
}
```

## R-FE-018 表单重置规范
关闭弹窗或重置搜索时，正确重置表单状态
```javascript
resetSearch() {
  this.$refs.searchForm.resetFields();
  this.searchForm = JSON.parse(JSON.stringify(this.defaultSearchForm));
  this.loadData();
},

handleModalClose() {
  this.showModal = false;
  this.$nextTick(() => {
    this.$refs.form.resetFields();
  });
}
```

## R-FE-019 深拷贝使用规范
编辑数据或保存默认值时使用深拷贝
```javascript
created() {
  this.defaultSearchForm = JSON.parse(JSON.stringify(this.searchForm));
},

handleEdit(row) {
  this.formData = JSON.parse(JSON.stringify(row));
  this.showModal = true;
},

// 简单对象可用展开运算符
handleEdit(row) {
  this.formData = { ...row };
}
```

## R-FE-020 日期格式化规范
使用 `dateFilters` 或字符串截取
```javascript
import { date, datetime } from '@/utils/dateFilters'

{
  title: '申请日期',
  key: 'applyTime',
  render: (h, params) => {
    return h('div', params.row.applyTime ? params.row.applyTime.split(' ')[0] : '')
  }
}
```

## R-FE-021 权限按钮使用
使用 `PermButton`/`PermLink` 控制操作权限
```javascript
{
  title: '操作',
  render: (h, params) => {
    return h('div', [
      h('PermLink', {
        props: { permCode: 'btn_edit' },
        on: {
          click: () => this.handleEdit(params.row)
        }
      }, '编辑'),
      h('PermButton', {
        props: {
          permCode: 'btn_delete',
          type: 'error',
          size: 'small'
        },
        on: {
          click: () => this.handleDelete(params.row)
        }
      }, '删除')
    ])
  }
}
```

## R-FE-022 父子组件通信规范
父传子用 `props`，子传父用 `$emit`
```javascript
// 父组件
<ChildComponent
  :data="parentData"
  @update="handleUpdate"
  @save="handleSave"
/>

// 子组件
export default {
  props: {
    data: {
      type: Object,
      default: () => ({})
    }
  },
  methods: {
    handleClick() {
      this.$emit('update', this.localData);
    }
  }
}
```

## R-FE-023 异步操作统一模式
```javascript
async handleAction() {
  this.loading = true;
  try {
    const res = await this.$API.someApi(params);
    if (!res.code) {
      this.$Message.success('操作成功');
      this.loadData();
    } else {
      this.$Message.error(res.msg);
    }
  } catch (e) {
    console.error(e);
    this.$Message.error('操作失败');
  } finally {
    this.loading = false;
  }
}
```
