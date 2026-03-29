import { writeFileSync } from 'fs';
import { join } from 'path';

// Basic carbon factors database (kg CO2e per unit)
export const carbonFactors = {
  transportation: {
    car_gasoline: {
      factor: 2.31, // kg CO2e per liter
      description: "汽油车碳排放因子",
      source: "IPCC 2006 Guidelines"
    },
    car_diesel: {
      factor: 2.68, // kg CO2e per liter
      description: "柴油车碳排放因子",
      source: "IPCC 2006 Guidelines"
    },
    electric_car: {
      factor: 0.058, // kg CO2e per km (assuming Chinese grid average)
      description: "电动车碳排放因子",
      source: "中国电力平均排放因子"
    },
    bus: {
      factor: 0.089, // kg CO2e per passenger-km
      description: "公交车碳排放因子",
      source: "中国交通运输数据"
    },
    subway: {
      factor: 0.047, // kg CO2e per passenger-km
      description: "地铁碳排放因子",
      source: "中国城市轨道交通数据"
    },
    train: {
      factor: 0.041, // kg CO2e per passenger-km
      description: "火车碳排放因子",
      source: "中国铁路数据"
    },
    airplane: {
      factor: 0.255, // kg CO2e per passenger-km
      description: "飞机碳排放因子",
      source: "ICAO emissions calculator"
    }
  },
  food: {
    beef: {
      factor: 27.0, // kg CO2e per kg
      description: "牛肉碳排放因子",
      source: "Poore & Nemecek (2018)"
    },
    pork: {
      factor: 12.1, // kg CO2e per kg
      description: "猪肉碳排放因子",
      source: "Poore & Nemecek (2018)"
    },
    chicken: {
      factor: 6.9, // kg CO2e per kg
      description: "鸡肉碳排放因子",
      source: "Poore & Nemecek (2018)"
    },
    rice: {
      factor: 4.0, // kg CO2e per kg
      description: "米饭碳排放因子",
      source: "中国水稻研究所"
    },
    vegetables: {
      factor: 0.4, // kg CO2e per kg
      description: "蔬菜碳排放因子",
      source: "FAO data"
    },
    fruits: {
      factor: 1.0, // kg CO2e per kg
      description: "水果碳排放因子",
      source: "FAO data"
    }
  },
  energy: {
    electricity: {
      factor: 0.58, // kg CO2e per kWh (China average)
      description: "中国电力平均排放因子",
      source: "国家能源局"
    },
    natural_gas: {
      factor: 2.16, // kg CO2e per cubic meter
      description: "天然气碳排放因子",
      source: "中国天然气数据"
    },
    coal: {
      factor: 2.77, // kg CO2e per kg
      description: "煤炭碳排放因子",
      source: "中国煤炭数据"
    },
    heating: {
      factor: 0.034, // kg CO2e per MJ
      description: "供暖碳排放因子",
      source: "中国供热数据"
    }
  },
  shopping: {
    clothes: {
      factor: 27.0, // kg CO2e per kg
      description: "服装碳排放因子",
      source: "时尚产业环保报告"
    },
    electronics: {
      factor: 370.0, // kg CO2e per kg
      description: "电子产品碳排放因子",
      source: "电子产品生命周期评估"
    },
    furniture: {
      factor: 50.0, // kg CO2e per kg
      description: "家具碳排放因子",
      source: "家具行业数据"
    },
    books: {
      factor: 3.0, // kg CO2e per kg
      description: "书籍碳排放因子",
      source: "出版业数据"
    }
  },
  housing: {
    water: {
      factor: 0.346, // kg CO2e per cubic meter
      description: "自来水处理碳排放因子",
      source: "水务行业数据"
    },
    waste: {
      factor: 0.5, // kg CO2e per kg
      description: "垃圾处理碳排放因子",
      source: "环保行业数据"
    },
    construction: {
      factor: 480.0, // kg CO2e per sqm
      description: "建筑建造碳排放因子",
      source: "建筑业数据"
    }
  },
  waste: {
    landfill: {
      factor: 0.5, // kg CO2e per kg
      description: "填埋处理碳排放因子",
      source: "环保行业数据"
    },
    recycling: {
      factor: -0.3, // kg CO2e per kg (negative for recycling)
      description: "回收处理碳排放因子",
      source: "循环经济数据"
    },
    composting: {
      factor: 0.1, // kg CO2e per kg
      description: "堆肥处理碳排放因子",
      source: "有机处理数据"
    }
  }
};

export function initCarbonFactors() {
  try {
    const dataPath = join(process.cwd(), 'data');
    const factorsPath = join(dataPath, 'carbon-factors.json');
    
    // Ensure data directory exists
    const fs = require('fs');
    if (!fs.existsSync(dataPath)) {
      fs.mkdirSync(dataPath, { recursive: true });
    }
    
    // Write carbon factors data
    writeFileSync(factorsPath, JSON.stringify(carbonFactors, null, 2));
    console.log('✅ Carbon factors data initialized');
    return true;
  } catch (error) {
    console.error('❌ Failed to initialize carbon factors data:', error);
    return false;
  }
}

export function getCarbonFactor(category: string, type: string): number | null {
  const categoryData = (carbonFactors as any)[category];
  if (!categoryData) return null;
  
  const typeData = categoryData[type];
  if (!typeData) return null;
  
  return typeData.factor;
}

export function getAllCarbonFactors() {
  return carbonFactors;
}