import { createContext, useContext, useState, useMemo } from "react"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type TenantResult = Record<string, any>

interface TenantContextType {
  tenants: TenantResult[]
  selectedIndex: number
  selectedTenant: TenantResult
  setSelectedIndex: (index: number) => void
}

const TenantContext = createContext<TenantContextType | null>(null)

export function useTenant(): TenantContextType {
  const ctx = useContext(TenantContext)
  if (!ctx) {
    throw new Error("useTenant must be used within a TenantProvider")
  }
  return ctx
}

interface TenantProviderProps {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  testResults: any
  children: React.ReactNode
}

/**
 * Normalizes test results into a multi-tenant array.
 * Supports both legacy single-tenant format and new multi-tenant format.
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function normalizeTenants(testResults: any): TenantResult[] {
  let rawTenants: any[] = [];
  if (Array.isArray(testResults?.Tenants) && testResults.Tenants.length > 0) {
    rawTenants = testResults.Tenants;
  } else if (testResults) {
    rawTenants = [testResults];
  } else {
    rawTenants = [];
  }

  // Detect if a specific standard tag was requested in Pester filter configuration
  const requestedTags: string[] = Array.isArray(testResults?.PesterConfig?.Filter?.Tag)
    ? testResults.PesterConfig.Filter.Tag.map((t: any) => String(t).toUpperCase())
    : [];

  const isCisTargeted = requestedTags.some(t => t.includes("CIS"));
  const isIso27001Targeted = requestedTags.some(t => t.includes("ISO 27001") || t.includes("ISO27001"));
  const isIso27002Targeted = requestedTags.some(t => t.includes("ISO 27002") || t.includes("ISO27002"));

  return rawTenants.map((tenant) => {
    if (!tenant || !Array.isArray(tenant.Tests)) {
      return tenant;
    }

    // Determine the active framework based on requested tags or actual test tags
    let activeFramework = "";
    if (isCisTargeted) {
      activeFramework = "CIS";
    } else if (isIso27001Targeted) {
      activeFramework = "ISO 27001";
    } else if (isIso27002Targeted) {
      activeFramework = "ISO 27002";
    } else {
      // Auto-detect based on what tags are actually present in the run
      const hasIso27001 = tenant.Tests.some((test: any) =>
        Array.isArray(test.Tag) && test.Tag.some((t: any) => typeof t === 'string' && t.toUpperCase().includes('ISO 27001'))
      );
      const hasIso27002 = tenant.Tests.some((test: any) =>
        Array.isArray(test.Tag) && test.Tag.some((t: any) => typeof t === 'string' && t.toUpperCase().includes('ISO 27002'))
      );
      const hasCis = tenant.Tests.some((test: any) =>
        (test.Block && test.Block.toUpperCase() === 'CIS') ||
        (Array.isArray(test.Tag) && test.Tag.some((t: any) => typeof t === 'string' && t.toUpperCase().includes('CIS')))
      );

      if (hasIso27001 && !hasCis && !hasIso27002) {
        activeFramework = "ISO 27001";
      } else if (hasIso27002 && !hasCis && !hasIso27001) {
        activeFramework = "ISO 27002";
      } else if (hasCis && !hasIso27001 && !hasIso27002) {
        activeFramework = "CIS";
      }
    }

    // Filter tests by active framework (if determined). Otherwise, keep all.
    const filteredTests = tenant.Tests.filter((test: any) => {
      if (!activeFramework) {
        // Keep all compliance/standard tests
        const hasBlock = test.Block && ["CIS", "CISA", "ISO 27001", "ISO 27002", "EIDSCA"].some(f => test.Block.toUpperCase().includes(f));
        const hasTag = Array.isArray(test.Tag) && test.Tag.some((t: any) =>
          typeof t === 'string' && ["CIS", "CISA", "ISO 27001", "ISO 27002", "EIDSCA"].some(f => t.toUpperCase().includes(f))
        );
        return hasBlock || hasTag;
      }

      if (activeFramework === "ISO 27001") {
        return Array.isArray(test.Tag) && test.Tag.some((t: any) => typeof t === 'string' && t.toUpperCase().includes('ISO 27001'));
      }
      if (activeFramework === "ISO 27002") {
        return Array.isArray(test.Tag) && test.Tag.some((t: any) => typeof t === 'string' && t.toUpperCase().includes('ISO 27002'));
      }
      // CIS
      const hasCisBlock = test.Block && test.Block.toUpperCase() === 'CIS';
      const hasCisTag = Array.isArray(test.Tag) && test.Tag.some((t: any) => typeof t === 'string' && t.toUpperCase().includes('CIS'));
      return hasCisBlock || hasCisTag;
    });

    const nonSkippedTests = filteredTests.filter((t: any) => t.Result !== 'Skipped');
    const skippedTests = filteredTests.filter((t: any) => t.Result === 'Skipped');
    const sortedFilteredTests = [...nonSkippedTests, ...skippedTests];

    const passedCount = sortedFilteredTests.filter((t: any) => t.Result === 'Passed').length;
    const failedCount = sortedFilteredTests.filter((t: any) => t.Result === 'Failed').length;
    const errorCount = sortedFilteredTests.filter((t: any) => t.Result === 'Error').length;
    const investigateCount = sortedFilteredTests.filter((t: any) => t.Result === 'Investigate').length;
    const skippedCount = sortedFilteredTests.filter((t: any) => t.Result === 'Skipped').length;
    const notRunCount = sortedFilteredTests.filter((t: any) => t.Result === 'NotRun').length;
    const totalCount = sortedFilteredTests.length;

    // Adjust blocks to match the active framework or show all matching blocks
    const filteredBlocks = Array.isArray(tenant.Blocks)
      ? tenant.Blocks.filter((block: any) => {
          if (!activeFramework) return true;
          if (activeFramework === 'CIS') {
            return block.Name && block.Name.toUpperCase() === 'CIS';
          } else {
            return block.Name && block.Name.toUpperCase().includes(activeFramework);
          }
        })
      : [];

    if (filteredBlocks.length === 0 && filteredTests.length > 0) {
      filteredBlocks.push({
        Name: activeFramework || "Compliance Tests",
        PassedCount: passedCount,
        FailedCount: failedCount,
        ErrorCount: errorCount,
        InvestigateCount: investigateCount,
        SkippedCount: skippedCount,
        NotRunCount: notRunCount,
        TotalCount: totalCount,
      });
    } else {
      for (let i = 0; i < filteredBlocks.length; i++) {
        filteredBlocks[i] = {
          ...filteredBlocks[i],
          PassedCount: passedCount,
          FailedCount: failedCount,
          ErrorCount: errorCount,
          InvestigateCount: investigateCount,
          SkippedCount: skippedCount,
          NotRunCount: notRunCount,
          TotalCount: totalCount,
        };
      }
    }

    return {
      ...tenant,
      Tests: sortedFilteredTests,
      Blocks: filteredBlocks,
      PassedCount: passedCount,
      FailedCount: failedCount,
      ErrorCount: errorCount,
      InvestigateCount: investigateCount,
      SkippedCount: skippedCount,
      NotRunCount: notRunCount,
      TotalCount: totalCount,
    };
  });
}

export function TenantProvider({ testResults, children }: TenantProviderProps) {
  const tenants = useMemo(() => normalizeTenants(testResults), [testResults])
  const [selectedIndex, setSelectedIndex] = useState(0)
  const selectedTenant = tenants[selectedIndex] ?? tenants[0]

  const value = useMemo(
    () => ({ tenants, selectedIndex, selectedTenant, setSelectedIndex }),
    [tenants, selectedIndex, selectedTenant]
  )

  return (
    <TenantContext.Provider value={value}>
      {children}
    </TenantContext.Provider>
  )
}
