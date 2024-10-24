import { useState } from 'react'
import { Input } from "@/components/ui/input"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"

const userData = [
  { id: 1, name: 'Alice Johnson', email: 'alice@example.com', role: 'Admin', lastLogin: '2023-05-15' },
  { id: 2, name: 'Bob Smith', email: 'bob@example.com', role: 'User', lastLogin: '2023-05-14' },
  { id: 3, name: 'Charlie Brown', email: 'charlie@example.com', role: 'User', lastLogin: '2023-05-13' },
  { id: 4, name: 'Diana Ross', email: 'diana@example.com', role: 'Manager', lastLogin: '2023-05-12' },
  { id: 5, name: 'Edward Norton', email: 'edward@example.com', role: 'User', lastLogin: '2023-05-11' },
]

export function UsersTab() {
  const [searchTerm, setSearchTerm] = useState('')

  const filteredUsers = userData.filter(user =>
    user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.role.toLowerCase().includes(searchTerm.toLowerCase())
  )

  return (
    <div className="space-y-4">
      <h2 className="text-xl font-semibold mb-4">User Management</h2>
      <Input
        placeholder="Search users..."
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
      />
      <div className="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-[100px]">ID</TableHead>
              <TableHead>Name</TableHead>
              <TableHead>Email</TableHead>
              <TableHead>Role</TableHead>
              <TableHead>Last Login</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredUsers.map((user) => (
              <TableRow key={user.id}>
                <TableCell className="font-medium">{user.id}</TableCell>
                <TableCell>{user.name}</TableCell>
                <TableCell>{user.email}</TableCell>
                <TableCell>{user.role}</TableCell>
                <TableCell>{user.lastLogin}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}