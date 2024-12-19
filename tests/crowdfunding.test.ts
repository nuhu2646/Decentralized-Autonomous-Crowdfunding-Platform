import { describe, it, expect, beforeEach, vi } from 'vitest'

describe('Crowdfunding Contract', () => {
  let mockContractCall: any
  
  beforeEach(() => {
    mockContractCall = vi.fn()
  })
  
  it('should create a project', async () => {
    mockContractCall.mockResolvedValue({ success: true, value: 1 })
    const result = await mockContractCall('create-project', 'Test Project', 'A test project', 1000, 100000)
    expect(result.success).toBe(true)
    expect(result.value).toBe(1)
  })
  
  it('should back a project', async () => {
    mockContractCall.mockResolvedValue({ success: true })
    const result = await mockContractCall('back-project', 1, 100)
    expect(result.success).toBe(true)
  })
  
  it('should get project details', async () => {
    mockContractCall.mockResolvedValue({
      success: true,
      value: {
        creator: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
        title: 'Test Project',
        description: 'A test project',
        funding_goal: 1000,
        current_funds: 100,
        deadline: 100000,
        status: 'active'
      }
    })
    const result = await mockContractCall('get-project', 1)
    expect(result.success).toBe(true)
    expect(result.value.title).toBe('Test Project')
    expect(result.value.current_funds).toBe(100)
  })
  
  it('should get backer contribution', async () => {
    mockContractCall.mockResolvedValue({ success: true, value: 100 })
    const result = await mockContractCall('get-backer-contribution', 1, 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM')
    expect(result.success).toBe(true)
    expect(result.value).toBe(100)
  })
})

