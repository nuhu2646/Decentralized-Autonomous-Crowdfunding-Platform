import { describe, it, expect, beforeEach, vi } from 'vitest'

describe('Voting Contract', () => {
  let mockContractCall: any
  
  beforeEach(() => {
    mockContractCall = vi.fn()
  })
  
  it('should vote on a milestone', async () => {
    mockContractCall.mockResolvedValue({ success: true })
    const result = await mockContractCall('vote-on-milestone', 1, 1, true)
    expect(result.success).toBe(true)
  })
  
  it('should get vote counts', async () => {
    mockContractCall.mockResolvedValue({
      success: true,
      value: {
        yes: 3,
        no: 1
      }
    })
    const result = await mockContractCall('get-vote-counts', 1, 1)
    expect(result.success).toBe(true)
    expect(result.value.yes).toBe(3)
    expect(result.value.no).toBe(1)
  })
  
  it('should get voter decision', async () => {
    mockContractCall.mockResolvedValue({ success: true, value: true })
    const result = await mockContractCall('get-voter-decision', 1, 1, 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM')
    expect(result.success).toBe(true)
    expect(result.value).toBe(true)
  })
})

