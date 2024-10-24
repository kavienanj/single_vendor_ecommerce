'use client'

import { useState } from 'react'
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import {
  BarChart as RechartsBarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
} from 'recharts'

interface ReportData {
  type: 'bar' | 'pie'
  data: { [key: string]: any }[]
}

export function ReportsTab() {
  const [selectedReport, setSelectedReport] = useState('')
  const [reportYear, setReportYear] = useState('')
  const [reportPeriod, setReportPeriod] = useState('')
  const [reportData, setReportData] = useState<ReportData | null>(null)

  const generateReport = () => {
    // Simulated report data generation
    switch (selectedReport) {
      case 'quarterly':
        setReportData({
          type: 'bar',
          data: [
            { quarter: 'Q1', sales: 12000 },
            { quarter: 'Q2', sales: 19000 },
            { quarter: 'Q3', sales: 15000 },
            { quarter: 'Q4', sales: 22000 },
          ]
        })
        break
      case 'topProducts':
        setReportData({
          type: 'bar',
          data: [
            { product: 'Widget A', sales: 1200 },
            { product: 'Gadget B', sales: 980 },
            { product: 'Doohickey C', sales: 850 },
            { product: 'Thingamajig D', sales: 750 },
            { product: 'Whatchamacallit E', sales: 600 },
          ]
        })
        break
      case 'categoryOrders':
        setReportData({
          type: 'pie',
          data: [
            { category: 'Electronics', value: 400 },
            { category: 'Clothing', value: 300 },
            { category: 'Books', value: 200 },
            { category: 'Home & Garden', value: 150 },
            { category: 'Toys', value: 100 },
          ]
        })
        break
      case 'productInterest':
        setReportData({
          type: 'bar',
          data: [
            { period: 'Jan', interest: 50 },
            { period: 'Feb', interest: 80 },
            { period: 'Mar', interest: 120 },
            { period: 'Apr', interest: 90 },
            { period: 'May', interest: 110 },
            { period: 'Jun', interest: 150 },
          ]
        })
        break
    }
  }

  const renderChart = () => {
    if (!reportData) return null

    if (reportData.type === 'bar') {
      return (
        <ResponsiveContainer width="100%" height={300}>
          <RechartsBarChart data={reportData.data}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey={Object.keys(reportData.data[0])[0]} />
            <YAxis />
            <Tooltip />
            <Legend />
            <Bar dataKey={Object.keys(reportData.data[0])[1]} fill="#8884d8" />
          </RechartsBarChart>
        </ResponsiveContainer>
      )
    } else if (reportData.type === 'pie') {
      const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8']
      return (
        <ResponsiveContainer width="100%" height={300}>
          <PieChart>
            <Pie
              data={reportData.data}
              cx="50%"
              cy="50%"
              outerRadius={100}
              fill="#8884d8"
              dataKey="value"
              label={({ category, percent }) => `${category} ${(percent * 100).toFixed(0)}%`}
            >
              {reportData.data.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
              ))}
            </Pie>
            <Tooltip />
            <Legend />
          </PieChart>
        </ResponsiveContainer>
      )
    }
  }

  return (
    <div className="space-y-4">
      <h2 className="text-xl font-semibold mb-4">Reports</h2>
      <div className="flex flex-col space-y-4">
        <div className="space-y-2">
          <label htmlFor="report-type" className="block text-sm font-medium text-gray-700">
            Select Report Type
          </label>
          <Select onValueChange={setSelectedReport}>
            <SelectTrigger id="report-type">
              <SelectValue placeholder="Select a report type" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="quarterly">Quarterly Sales Report</SelectItem>
              <SelectItem value="topProducts">Top Selling Products</SelectItem>
              <SelectItem value="categoryOrders">Product Category Orders</SelectItem>
              <SelectItem value="productInterest">Product Interest Over Time</SelectItem>
            </SelectContent>
          </Select>
        </div>
        {selectedReport && (
          <div className="space-y-2">
            {(selectedReport === 'quarterly' || selectedReport === 'topProducts') && (
              <div>
                <label htmlFor="report-year" className="block text-sm font-medium text-gray-700">
                  Year
                </label>
                <Input
                  id="report-year"
                  type="number"
                  placeholder="Enter year"
                  value={reportYear}
                  onChange={(e) => setReportYear(e.target.value)}
                />
              </div>
            )}
            {(selectedReport === 'topProducts' || selectedReport === 'categoryOrders' || selectedReport === 'productInterest') && (
              <div>
                <label htmlFor="report-period" className="block text-sm font-medium text-gray-700">
                  Time Period
                </label>
                <Input
                  id="report-period"
                  placeholder="e.g., Last 30 days, Q2 2023"
                  value={reportPeriod}
                  onChange={(e) => setReportPeriod(e.target.value)}
                />
              </div>
            )}
          </div>
        )}
      </div>
      <Button onClick={generateReport} disabled={!selectedReport}>Generate Report</Button>
      {reportData && (
        <div className="mt-8">
          <h3 className="text-lg font-semibold mt-8 mb-4">
            {selectedReport === 'quarterly' && `Quarterly Sales Report for ${reportYear}`}
            {selectedReport === 'topProducts' && `Top Selling Products in ${reportPeriod}`}
            {selectedReport === 'categoryOrders' && `Product Category Orders in ${reportPeriod}`}
            {selectedReport === 'productInterest' && `Product Interest Over ${reportPeriod}`}
          </h3>
          {renderChart()}
        </div>
      )}
    </div>
  )
}
