#!/usr/bin/env python3
"""
Simple test script for KUHP Analyzer API
Run this to test the backend functionality
"""

import requests
import json
import sys

def test_api(base_url="http://localhost:8080"):
    print(f"Testing KUHP Analyzer API at {base_url}")
    print("=" * 50)
    
    # Test health check
    try:
        response = requests.get(f"{base_url}/health", timeout=10)
        if response.status_code == 200:
            print("[PASS] Health check passed")
        else:
            print(f"[FAIL] Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"[ERROR] Health check error: {e}")
        return False
    
    # Test root endpoint
    try:
        response = requests.get(f"{base_url}/", timeout=10)
        if response.status_code == 200:
            print("[PASS] Root endpoint accessible")
        else:
            print(f"[FAIL] Root endpoint failed: {response.status_code}")
    except Exception as e:
        print(f"[ERROR] Root endpoint error: {e}")
    
    # Test analyze endpoint with valid query
    test_queries = [
        "Pasal 351 tentang penganiayaan",
        "perbedaan pidana pembunuhan",
        "sanksi pencurian",
        "pertanyaan di luar KUHP"  # This should be rejected
    ]
    
    for i, query in enumerate(test_queries, 1):
        print(f"\nTest {i}: Testing query - '{query}'")
        try:
            payload = {"query": query}
            response = requests.post(
                f"{base_url}/analyze", 
                json=payload, 
                timeout=30,
                headers={"Content-Type": "application/json"}
            )
            
            if response.status_code == 200:
                result = response.json()
                print(f"[PASS] Query processed successfully")
                print(f"   Relevant: {result.get('is_relevant', 'Unknown')}")
                print(f"   Response length: {len(result.get('response', ''))} characters")
                if len(result.get('response', '')) > 100:
                    print(f"   Response preview: {result.get('response', '')[:100]}...")
                else:
                    print(f"   Response: {result.get('response', '')}")
            else:
                print(f"[FAIL] Query failed: {response.status_code}")
                print(f"   Error: {response.text}")
                
        except Exception as e:
            print(f"[ERROR] Query error: {e}")
    
    print("\n" + "=" * 50)
    print("API testing completed!")

if __name__ == "__main__":
    base_url = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8080"
    test_api(base_url)