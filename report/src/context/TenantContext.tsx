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

  // Detect if a specific standard tag was requested in Pester filter configuration or path
  const requestedTags: string[] = Array.isArray(testResults?.PesterConfig?.Filter?.Tag)
    ? testResults.PesterConfig.Filter.Tag.map((t: any) => String(t).toUpperCase())
    : [];

  const runPaths: string[] = Array.isArray(testResults?.PesterConfig?.Run?.Path)
    ? testResults.PesterConfig.Run.Path.map((p: any) => String(p).toUpperCase())
    : [];

  const invokeCmd = typeof testResults?.InvokeCommand === 'string' ? testResults.InvokeCommand.toUpperCase() : "";

  const isCisTargeted = requestedTags.some(t => t.includes("CIS")) || runPaths.some(p => p.includes("CIS")) || invokeCmd.includes("-TAG 'CIS'");
  const isIso27001Targeted = requestedTags.some(t => t.includes("ISO 27001") || t.includes("ISO27001")) || runPaths.some(p => p.includes("ISO27001"));
  const isIso27002Targeted = requestedTags.some(t => t.includes("ISO 27002") || t.includes("ISO27002")) || runPaths.some(p => p.includes("ISO27002"));
  const isDpdpTargeted = requestedTags.some(t => t.includes("DPDP")) || runPaths.some(p => p.includes("DPDP")) || invokeCmd.includes("DPDP");
  const isCisaTargeted = requestedTags.some(t => t.includes("CISA")) || runPaths.some(p => p.includes("CISA"));
  const isEidscaTargeted = requestedTags.some(t => t.includes("EIDSCA")) || runPaths.some(p => p.includes("EIDSCA"));
  const isOrcaTargeted = requestedTags.some(t => t.includes("ORCA")) || runPaths.some(p => p.includes("ORCA"));

  return rawTenants.map((tenant) => {
    if (!tenant || !Array.isArray(tenant.Tests)) {
      return tenant;
    }

    // Determine the active framework based on requested tags, paths, or actual test tags
    let activeFramework = "";
    if (isDpdpTargeted) {
      activeFramework = "DPDP";
    } else if (isCisTargeted) {
      activeFramework = "CIS";
    } else if (isIso27001Targeted) {
      activeFramework = "ISO 27001";
    } else if (isIso27002Targeted) {
      activeFramework = "ISO 27002";
    } else if (isCisaTargeted) {
      activeFramework = "CISA";
    } else if (isEidscaTargeted) {
      activeFramework = "EIDSCA";
    } else if (isOrcaTargeted) {
      activeFramework = "ORCA";
    } else {
      // Auto-detect based on what tags are actually present in the run
      const hasDpdp = tenant.Tests.some((test: any) =>
        (test.Id && test.Id.toUpperCase().startsWith('DPDP')) ||
        (test.Block && test.Block.toUpperCase().includes('DPDP')) ||
        (Array.isArray(test.Tag) && test.Tag.some((t: any) => typeof t === 'string' && t.toUpperCase().includes('DPDP')))
      );
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

      if (hasDpdp && !hasCis && !hasIso27001 && !hasIso27002) {
        activeFramework = "DPDP";
      } else if (hasIso27001 && !hasCis && !hasIso27002 && !hasDpdp) {
        activeFramework = "ISO 27001";
      } else if (hasIso27002 && !hasCis && !hasIso27001 && !hasDpdp) {
        activeFramework = "ISO 27002";
      } else if (hasCis && !hasIso27001 && !hasIso27002 && !hasDpdp) {
        activeFramework = "CIS";
      }
    }

    // Filter tests by active framework (if determined). Otherwise, keep all.
    const filteredTests = tenant.Tests.filter((test: any) => {
      if (!activeFramework) {
        return true;
      }

      if (activeFramework === "DPDP") {
        return (test.Id && test.Id.toUpperCase().startsWith('DPDP')) ||
               (test.Block && test.Block.toUpperCase().includes('DPDP')) ||
               (Array.isArray(test.Tag) && test.Tag.some((t: any) => typeof t === 'string' && t.toUpperCase().includes('DPDP')));
      }
      if (activeFramework === "ISO 27001") {
        return Array.isArray(test.Tag) && test.Tag.some((t: any) => typeof t === 'string' && t.toUpperCase().includes('ISO 27001'));
      }
      if (activeFramework === "ISO 27002") {
        return Array.isArray(test.Tag) && test.Tag.some((t: any) => typeof t === 'string' && t.toUpperCase().includes('ISO 27002'));
      }
      if (activeFramework === "CIS") {
        const hasCisBlock = test.Block && test.Block.toUpperCase() === 'CIS';
        const hasCisTag = Array.isArray(test.Tag) && test.Tag.some((t: any) => typeof t === 'string' && t.toUpperCase().includes('CIS'));
        return hasCisBlock || hasCisTag;
      }
      if (activeFramework === "CISA") {
        return (test.Id && test.Id.toUpperCase().startsWith('CISA')) || (Array.isArray(test.Tag) && test.Tag.some((t: any) => typeof t === 'string' && t.toUpperCase().includes('CISA')));
      }
      if (activeFramework === "EIDSCA") {
        return (test.Id && test.Id.toUpperCase().startsWith('EIDSCA')) || (Array.isArray(test.Tag) && test.Tag.some((t: any) => typeof t === 'string' && t.toUpperCase().includes('EIDSCA')));
      }
      if (activeFramework === "ORCA") {
        return (test.Id && test.Id.toUpperCase().startsWith('ORCA')) || (Array.isArray(test.Tag) && test.Tag.some((t: any) => typeof t === 'string' && t.toUpperCase().includes('ORCA')));
      }

      return true;
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
