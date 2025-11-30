'use client'

import { useState, useEffect } from 'react'
import axios from 'axios'
import { Send, FileText, AlertCircle, Scale, ArrowRight } from 'lucide-react'

interface PasalDetail {
  pasal: string | null
  judul: string | null
  isi: string | null
  sanksi: string | null
}

interface PasalComparison {
  topik: string
  kuhp_lama: PasalDetail | null
  kuhp_baru: PasalDetail | null
  perbedaan: string[] | null
}

interface ComparisonData {
  ringkasan: string | null
  pasal_terkait: PasalComparison[] | null
  analisis_perubahan: string | null
  kesimpulan: string | null
}

interface AnalysisResponse {
  response: string
  is_relevant: boolean
  comparison_data: ComparisonData | null
}

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080'

export default function Home() {
  const [query, setQuery] = useState('')
  const [loading, setLoading] = useState(false)
  const [result, setResult] = useState<AnalysisResponse | null>(null)
  const [error, setError] = useState('')

  // Log API URL untuk debugging
  useEffect(() => {
    console.log('Environment API URL:', process.env.NEXT_PUBLIC_API_URL)
    console.log('Final API URL:', API_URL)
  }, [])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!query.trim()) {
      setError('Silakan masukkan pasal atau kata kunci')
      return
    }

    setLoading(true)
    setError('')
    setResult(null)

    try {
      console.log('Using API URL:', API_URL)
      const response = await axios.post(`${API_URL}/analyze`, {
        query: query.trim()
      })

      setResult(response.data)
    } catch (err) {
      console.error('Error:', err)
      setError('Terjadi kesalahan saat menganalisis. Silakan coba lagi.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-4xl mx-auto">
          <div className="text-center mb-8">
            <div className="flex items-center justify-center mb-4">
              <FileText className="h-12 w-12 text-indigo-600 mr-3" />
              <h1 className="text-4xl font-bold text-gray-900">
                KUHP Analyzer
              </h1>
            </div>
            <p className="text-xl text-gray-600">
              Analisis Perbedaan KUHP Lama dan Baru dengan Google ADK
            </p>
            <p className="text-sm text-gray-500 mt-2">
              Masukkan pasal atau kata kunci untuk mengetahui perbedaan antara KUHP lama dan baru
            </p>
          </div>

          <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label htmlFor="query" className="block text-sm font-medium text-gray-700 mb-2">
                  Pasal atau Kata Kunci
                </label>
                <div className="relative">
                  <input
                    type="text"
                    id="query"
                    value={query}
                    onChange={(e) => setQuery(e.target.value)}
                    placeholder="Contoh: Pasal 351, pencurian, pembunuhan, dll."
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                    disabled={loading}
                  />
                </div>
              </div>

              {error && (
                <div className="flex items-center p-3 bg-red-50 border border-red-200 rounded-lg">
                  <AlertCircle className="h-5 w-5 text-red-500 mr-2" />
                  <span className="text-red-700">{error}</span>
                </div>
              )}

              <button
                type="submit"
                disabled={loading || !query.trim()}
                className="w-full bg-indigo-600 text-white py-3 px-4 rounded-lg hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2"
              >
                {loading ? (
                  <>
                    <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                    <span>Menganalisis...</span>
                  </>
                ) : (
                  <>
                    <Send className="h-5 w-5" />
                    <span>Analisis Perbedaan</span>
                  </>
                )}
              </button>
            </form>
          </div>

          {result && (
            <div className="space-y-6">
              {/* Header */}
              <div className="bg-white rounded-lg shadow-lg p-6">
                <div className="flex items-center mb-4">
                  {result.is_relevant ? (
                    <Scale className="h-6 w-6 text-indigo-600 mr-2" />
                  ) : (
                    <AlertCircle className="h-6 w-6 text-yellow-500 mr-2" />
                  )}
                  <h2 className="text-xl font-semibold text-gray-900">
                    {result.is_relevant ? 'Perbandingan KUHP' : 'Informasi'}
                  </h2>
                </div>

                {/* Ringkasan */}
                {result.comparison_data?.ringkasan && (
                  <div className="bg-indigo-50 border-l-4 border-indigo-500 p-4 mb-4">
                    <p className="text-indigo-900 font-medium">{result.comparison_data.ringkasan}</p>
                  </div>
                )}
              </div>

              {/* Side-by-Side Comparison */}
              {result.comparison_data?.pasal_terkait && result.comparison_data.pasal_terkait.length > 0 && (
                <div className="space-y-6">
                  {result.comparison_data.pasal_terkait.map((pasal, index) => (
                    <div key={index} className="bg-white rounded-lg shadow-lg overflow-hidden">
                      {/* Topik Header */}
                      <div className="bg-gray-800 text-white px-6 py-3">
                        <h3 className="text-lg font-semibold">{pasal.topik}</h3>
                      </div>

                      {/* Side by Side Content */}
                      <div className="grid grid-cols-1 md:grid-cols-2 divide-y md:divide-y-0 md:divide-x divide-gray-200">
                        {/* KUHP Lama */}
                        <div className="p-6 bg-red-50">
                          <div className="flex items-center mb-4">
                            <div className="bg-red-600 text-white px-3 py-1 rounded-full text-sm font-medium">
                              KUHP LAMA
                            </div>
                          </div>
                          {pasal.kuhp_lama ? (
                            <div className="space-y-3">
                              <div>
                                <span className="text-red-800 font-bold text-lg">{pasal.kuhp_lama.pasal}</span>
                                {pasal.kuhp_lama.judul && (
                                  <span className="text-red-700 ml-2">- {pasal.kuhp_lama.judul}</span>
                                )}
                              </div>
                              <div className="bg-white rounded-lg p-4 border border-red-200">
                                <p className="text-gray-800 text-sm leading-relaxed whitespace-pre-wrap">
                                  {pasal.kuhp_lama.isi}
                                </p>
                              </div>
                              {pasal.kuhp_lama.sanksi && (
                                <div className="bg-red-100 rounded-lg p-3">
                                  <span className="text-red-800 font-medium text-sm">Sanksi: </span>
                                  <span className="text-red-700 text-sm">{pasal.kuhp_lama.sanksi}</span>
                                </div>
                              )}
                            </div>
                          ) : (
                            <div className="text-gray-500 italic">Tidak ada pasal terkait di KUHP Lama</div>
                          )}
                        </div>

                        {/* KUHP Baru */}
                        <div className="p-6 bg-green-50">
                          <div className="flex items-center mb-4">
                            <div className="bg-green-600 text-white px-3 py-1 rounded-full text-sm font-medium">
                              KUHP BARU
                            </div>
                          </div>
                          {pasal.kuhp_baru ? (
                            <div className="space-y-3">
                              <div>
                                <span className="text-green-800 font-bold text-lg">{pasal.kuhp_baru.pasal}</span>
                                {pasal.kuhp_baru.judul && (
                                  <span className="text-green-700 ml-2">- {pasal.kuhp_baru.judul}</span>
                                )}
                              </div>
                              <div className="bg-white rounded-lg p-4 border border-green-200">
                                <p className="text-gray-800 text-sm leading-relaxed whitespace-pre-wrap">
                                  {pasal.kuhp_baru.isi}
                                </p>
                              </div>
                              {pasal.kuhp_baru.sanksi && (
                                <div className="bg-green-100 rounded-lg p-3">
                                  <span className="text-green-800 font-medium text-sm">Sanksi: </span>
                                  <span className="text-green-700 text-sm">{pasal.kuhp_baru.sanksi}</span>
                                </div>
                              )}
                            </div>
                          ) : (
                            <div className="text-gray-500 italic">Tidak ada pasal terkait di KUHP Baru</div>
                          )}
                        </div>
                      </div>

                      {/* Perbedaan */}
                      {pasal.perbedaan && pasal.perbedaan.length > 0 && (
                        <div className="bg-amber-50 px-6 py-4 border-t border-amber-200">
                          <h4 className="text-amber-800 font-semibold mb-2 flex items-center">
                            <ArrowRight className="h-4 w-4 mr-2" />
                            Perbedaan Utama:
                          </h4>
                          <ul className="list-disc list-inside space-y-1">
                            {pasal.perbedaan.map((diff, idx) => (
                              <li key={idx} className="text-amber-900 text-sm">{diff}</li>
                            ))}
                          </ul>
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              )}

              {/* Analisis & Kesimpulan */}
              {(result.comparison_data?.analisis_perubahan || result.comparison_data?.kesimpulan) && (
                <div className="bg-white rounded-lg shadow-lg p-6">
                  {result.comparison_data?.analisis_perubahan && (
                    <div className="mb-6">
                      <h3 className="text-lg font-semibold text-gray-900 mb-3">Analisis Perubahan</h3>
                      <p className="text-gray-700 leading-relaxed whitespace-pre-wrap">
                        {result.comparison_data.analisis_perubahan}
                      </p>
                    </div>
                  )}
                  {result.comparison_data?.kesimpulan && (
                    <div className="bg-blue-50 border-l-4 border-blue-500 p-4">
                      <h3 className="text-blue-900 font-semibold mb-2">Kesimpulan</h3>
                      <p className="text-blue-800">{result.comparison_data.kesimpulan}</p>
                    </div>
                  )}
                </div>
              )}

              {/* Fallback: Raw Response jika tidak ada comparison_data */}
              {!result.comparison_data && result.is_relevant && (
                <div className="bg-white rounded-lg shadow-lg p-6">
                  <div className="prose max-w-none">
                    <div className="whitespace-pre-wrap text-gray-800 leading-relaxed">
                      {result.response}
                    </div>
                  </div>
                </div>
              )}

              {/* Info jika query tidak relevan */}
              {!result.is_relevant && (
                <div className="bg-white rounded-lg shadow-lg p-6">
                  <div className="prose max-w-none">
                    <div className="whitespace-pre-wrap text-gray-800 leading-relaxed">
                      {result.response}
                    </div>
                  </div>
                  <div className="mt-4 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
                    <p className="text-yellow-800 text-sm">
                      Tip: Coba tanyakan tentang pasal-pasal spesifik, jenis kejahatan, atau konsep hukum yang ada dalam KUHP.
                    </p>
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      </div>

      <footer className="mt-12 text-center text-gray-500 text-sm">
        <p>© 2025 KUHP Analyzer - Powered by Google Agent Development Kit</p>
      </footer>
    </div>
  )
}