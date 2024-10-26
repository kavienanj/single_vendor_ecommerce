'use client';

import { useEffect, useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
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
} from 'recharts';
import { apiClient } from '@/services/axiosClient';
import { Product } from '@/contexts/EcommerceContext';
import { SelectProductsPopover } from './components/select-product-popover';

interface ReportData {
  type: 'bar' | 'pie';
  data: { [key: string]: any }[];
}

export function ReportsTab() {
  const [selectedReport, setSelectedReport] = useState('');
  const [reportYear, setReportYear] = useState('');
  const [startDate, setStartDate] = useState(''); // New state for start date
  const [endDate, setEndDate] = useState(''); // New state for end date
	const [products, setProducts] = useState<Product[]>([]);
  const [reportPeriod, setReportPeriod] = useState('');
  const [reportData, setReportData] = useState<ReportData | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const generateReport = async () => {
    setLoading(true);
    setError(null); // Clear previous errors
    setReportData(null); // Reset report data before generating

    try {
      let url = '';
      let queryParams = '';

      switch (selectedReport) {
        case 'quarterly':
          url += '/sales-report';
          queryParams = `?year=${reportYear}`;
          break;
          case 'topProducts':
            url += '/most-selling-product';
            queryParams = `?start_date=${startDate}&end_date=${endDate}`; // Use new states for dates
            break;
        case 'categoryOrders':
          url += '/most-orders';
          break;
        case 'productInterest':
          url += '/most-interest';
          queryParams = `?product_id=${reportPeriod}`; // Assuming reportPeriod holds product ID for this case
          break;
        case 'customerReport':
          url += '/customer-report';
          break;
        default:
          throw new Error('Invalid report type selected');
      }

      const response = await apiClient.get(url + queryParams);
      const data = await response.data;

      if (response.status !== 200) {
        throw new Error(data.message || 'Failed to generate report');
      }

      if (!data.data || data.data.length === 0) {
        throw new Error('No data found for the selected report');
      }

      // Handle the response based on the report type
      switch (selectedReport) {
        case 'quarterly':
          setReportData({ type: 'bar', data: data.data });
          break;
        case 'topProducts':
          setReportData({ type: 'bar', data: data.data });
          break;
        case 'categoryOrders':
          setReportData({ type: 'pie', data: data.data });
          break;
        case 'productInterest':
          setReportData({ type: 'pie', data: data.data });
          break;
        case 'customerReport':
          setReportData({ type: 'bar', data: data.data }); // Assuming bar chart for customer report
          break;
      }
    } catch (err: any) {
      setError(err.message || 'Error generating report');
    } finally {
      setLoading(false);
    }
  };

  const renderChart = () => {
    if (!reportData) return null;
    /*  */
    if (selectedReport === 'customerReport') {
      return (
        <div className="overflow-x-auto">
          <table className="min-w-full border border-gray-200 divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Customer Name</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Order ID</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Purchased Time</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Order Status</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Total Amount</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">No. Items</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Total Price</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {reportData.data.map((item, index) => (
                <tr key={index}>
                  <td className="px-4 py-2">{item.customer_name}</td>
                  <td className="px-4 py-2">{item.email}</td>
                  <td className="px-4 py-2">{item.order_id}</td>
                  <td className="px-4 py-2">{item.purchased_time}</td>
                  <td className="px-4 py-2">{item.order_status}</td>
                  <td className="px-4 py-2">{item.total_amount}</td>
                  <td className="px-4 py-2">{item.number_of_items}</td>
                  <td className="px-4 py-2">{item.total_price}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      );
    }
    if (reportData.type === 'bar') {
      const maxSalesValue = Math.max(...reportData.data.map(item => item.total_sales)); // Replace 'total_sales' with your actual sales key
      return (
        <ResponsiveContainer width="100%" height={300}>
          <RechartsBarChart data={reportData.data}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey={Object.keys(reportData.data[0])[0]} />
            <YAxis domain={[0, Math.ceil(maxSalesValue / 10) * 10]} /> {/* Set domain to extend the Y-axis */}
            <Tooltip />
            <Legend />
            <Bar dataKey={Object.keys(reportData.data[0])[1]} fill="#8884d8" />
          </RechartsBarChart>
        </ResponsiveContainer>
      );
    }
    
    if (reportData.type === 'pie') {
      //const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8'];
      const COLORS = [
        '#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8', 
        '#FF6347', '#36A2EB', '#A569BD', '#FF9F40', '#F08080', 
        '#FFD700', '#ADFF2F', '#40E0D0', '#FF4500', '#DA70D6'
    ];
    
      return (
        <ResponsiveContainer width="100%" height={300}>
          <PieChart>
            <Pie
              data={reportData.data}
              cx="50%"
              cy="50%"
              outerRadius={100}
              fill="#8884d8"
              dataKey={Object.keys(reportData.data[0])[1]} // Use the second key for values
              nameKey={Object.keys(reportData.data[0])[0]} // Use the first key for categories
              label={({ percent, name }) => `${name} ${(percent * 100).toFixed(0)}%`}
            >
              {reportData.data.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
              ))}
            </Pie>
            <Tooltip />
            <Legend />
          </PieChart>
        </ResponsiveContainer>
      );
    }
  }

	const fetchProducts = async () => {
		const fetchedProducts = await apiClient.get('/products').then(res => res.data);
		setProducts(fetchedProducts);
	};

  useEffect(() => {
    fetchProducts();
  }, []);

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
              <SelectItem value="categoryOrders">Top Product Categories</SelectItem>
              <SelectItem value="productInterest">Product Interest Over Time</SelectItem>
              <SelectItem value="customerReport">Customer Order Report</SelectItem>
            </SelectContent>
          </Select>
        </div>

        {selectedReport && (
          <div className="space-y-2">
            {(selectedReport === 'quarterly' ) && (
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
            {selectedReport === 'topProducts' && ( // New input fields for date range
              <div className="space-y-2">
                <div>
                  <label htmlFor="start-date" className="block text-sm font-medium text-gray-700">
                    Start Date
                  </label>
                  <Input
                    id="start-date"
                    type="date"
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                  />
                </div>
                <div>
                  <label htmlFor="end-date" className="block text-sm font-medium text-gray-700">
                    End Date
                  </label>
                  <Input
                    id="end-date"
                    type="date"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                  />
                </div>
              </div>
            )}
            {selectedReport === 'productInterest' && (
              <div>
                <label htmlFor="product-id" className="block text-sm font-medium text-gray-700">
                  Product ID
                </label>
                <SelectProductsPopover
                  products={products}
                  onSelect={(product) => setReportPeriod(product.product_id.toString())}
                />
              </div>
            )}
          </div>
        )}
      </div>

      <Button onClick={generateReport} disabled={!selectedReport || loading}>
        {loading ? 'Generating...' : 'Generate Report'}
      </Button>

      {error && <p className="text-red-500">{error}</p>}

      {reportData && (
        <div className="mt-8">
          <h3 className="text-lg font-semibold mt-8 mb-4">
            {selectedReport === 'quarterly' && `Quarterly Sales Report for ${reportYear}`}
            {selectedReport === 'topProducts' && `Top Selling Products Report`}
            {selectedReport === 'categoryOrders' && `Top Product Categories`}
            {selectedReport === 'productInterest' && `Product Interest for Product ID ${reportPeriod}`}
            {selectedReport === 'customerReport' && `Customer Order Report`}
          </h3>
          {renderChart()}
        </div>
      )}
    </div>
  );
}
