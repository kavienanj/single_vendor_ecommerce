'use client'

import { useEffect, useState } from 'react'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { Label } from '@/components/ui/label'
import { useAuth } from '@/contexts/AuthContext'
import { useRouter } from 'next/navigation'
import Link from 'next/link'

export function AuthPageComponent() {
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState('')
  const router = useRouter();
  const { user, isCustomer, isAdmin, registerUser, signin } = useAuth();

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setIsLoading(true)
    setError('')

    const formData = new FormData(event.currentTarget)
    const isSignUp = event.currentTarget.id === 'signup-form'

    if (isSignUp) {
      const email = formData.get('email') as string
      const first_name = formData.get('firstName') as string
      const last_name = formData.get('lastName') as string
      const password = formData.get('password') as string
      const confirmPassword = formData.get('confirmPassword') as string
      if (isSignUp && password !== confirmPassword) {
        setError('Passwords do not match')
        setIsLoading(false)
        return
      }
      const { success, message } = await registerUser({ email, first_name, last_name, password })
      if (!success) {
        setError(message)
      }
    } else {
      const email = formData.get('email') as string
      const password = formData.get('password') as string
      const { success, message } = await signin(email, password)
      if (!success) {
        setError(message)
      }
    }
    setIsLoading(false)
  }

  useEffect(() => {
    if (user && isCustomer()) {
      router.push('/')
    }
    if (user && isAdmin()) {
      router.push('/admin')
    }
  }, [user]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100">
      <Card className="w-[350px]">
        <CardHeader>
          <CardTitle>Welcome</CardTitle>
          <CardDescription>Sign in to your account or create a new one.</CardDescription>
        </CardHeader>
        <CardContent>
          <Tabs defaultValue="signin" className="w-full">
            <TabsList className="grid w-full grid-cols-2">
              <TabsTrigger value="signin">Sign In</TabsTrigger>
              <TabsTrigger value="signup">Sign Up</TabsTrigger>
            </TabsList>
            <TabsContent value="signin">
              <form id="signin-form" onSubmit={handleSubmit}>
                <div className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="signin-email">Email</Label>
                    <Input id="signin-email" name="email" type="email" required />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="signin-password">Password</Label>
                    <Input id="signin-password" name="password" type="password" required />
                  </div>
                </div>
                <Button className="w-full mt-4" type="submit" disabled={isLoading}>
                  {isLoading ? 'Signing in...' : 'Sign In'}
                </Button>
              </form>
            </TabsContent>
            <TabsContent value="signup">
              <form id="signup-form" onSubmit={handleSubmit}>
                <div className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="signup-email">Email</Label>
                    <Input id="signup-email" name="email" type="email" required />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="signup-first-name">First Name</Label>
                    <Input id="signup-first-name" name="firstName" required />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="signup-last-name">Last Name</Label>
                    <Input id="signup-last-name" name="lastName" required />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="signup-password">Password</Label>
                    <Input id="signup-password" name="password" type="password" required />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="signup-confirm-password">Confirm Password</Label>
                    <Input id="signup-confirm-password" name="confirmPassword" type="password" required />
                  </div>
                </div>
                <Button className="w-full mt-6" type="submit" disabled={isLoading}>
                  {isLoading ? 'Signing up...' : 'Sign Up'}
                </Button>
              </form>
            </TabsContent>
          </Tabs>
          <Link href="/" className="w-full">
            <Button className="mt-4 w-full" variant="secondary">
              Continue as guest
            </Button>
          </Link>
        </CardContent>
        {(error || isCustomer()) && (
          <CardFooter>
            {error && <p className="text-red-500 text-sm">{error}</p>}
            {user && isCustomer() && <p className="text-green-500 text-sm">Sign in successful</p>}
          </CardFooter>
        )}
      </Card>
    </div>
  )
}
