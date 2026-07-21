import { cx } from "@/lib/utils"
import {
  House,
  Eye,
  FileText,
  Printer,
  Table,
  ChevronUp,
  ChevronDown,
  Building2,
} from "lucide-react"
import { Link, useLocation } from "react-router-dom"
import React, { useState, createContext, useContext } from "react"
import m365advisorLogo from "@/assets/m365advisor.png"
import { useTenant } from "@/context/TenantContext"
import { scrollReportToTop } from "@/lib/reportLinks"

interface SidebarContextType {
  isCollapsed: boolean
  setIsCollapsed: (collapsed: boolean) => void
}

const SidebarContext = createContext<SidebarContextType>({
  isCollapsed: false,
  setIsCollapsed: () => { },
})

export const useSidebar = () => useContext(SidebarContext)

interface NavItemProps {
  href: string
  icon: React.ElementType
  label: string
  isActive?: boolean
  isCollapsed?: boolean
  onClick?: () => void
}

function NavItem({
  href,
  icon: Icon,
  label,
  isActive,
  isCollapsed,
  onClick,
}: NavItemProps) {
  return (
    <Link
      to={href}
      onClick={onClick}
      className={cx(
        "group relative flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium tracking-tight transition-all duration-100",
        isActive
          ? "bg-orange-50 text-orange-600 dark:bg-orange-950 dark:text-orange-400"
          : "text-gray-700 hover:bg-gray-100 hover:text-gray-900 dark:text-gray-300 dark:hover:bg-gray-800 dark:hover:text-gray-100"
      )}
    >
      <Icon className={cx("size-[18px] shrink-0", isCollapsed && "mx-auto")} />
      {!isCollapsed && <span>{label}</span>}
    </Link>
  )
}

interface NavGroupProps {
  icon: React.ElementType
  label: string
  isActive?: boolean
  isCollapsed?: boolean
  children: React.ReactNode
  defaultOpen?: boolean
}

function NavGroup({
  icon: Icon,
  label,
  isActive,
  isCollapsed,
  children,
  defaultOpen = false,
}: NavGroupProps) {
  const [isOpen, setIsOpen] = useState(defaultOpen || isActive)

  return (
    <div>
      <button
        onClick={() => setIsOpen(!isOpen)}
        className={cx(
          "group relative flex w-full items-center justify-between gap-3 rounded-md px-3 py-2 text-sm font-medium tracking-tight transition-all duration-100",
          isActive
            ? "bg-orange-50 text-orange-600 dark:bg-orange-950 dark:text-orange-400"
            : "text-gray-700 hover:bg-gray-100 hover:text-gray-900 dark:text-gray-300 dark:hover:bg-gray-800 dark:hover:text-gray-100"
        )}
      >
        <div className="flex items-center gap-3">
          <Icon className={cx("size-[18px] shrink-0", isCollapsed && "mx-auto")} />
          {!isCollapsed && <span>{label}</span>}
        </div>
        {!isCollapsed && (
          isOpen ? (
            <ChevronUp className="h-4 w-4 text-gray-400 dark:text-gray-500" />
          ) : (
            <ChevronDown className="h-4 w-4 text-gray-400 dark:text-gray-500" />
          )
        )}
      </button>
      {isOpen && !isCollapsed && (
        <div className="relative ml-4 mt-1 space-y-0.5 pl-4">
          {/* Vertical connecting line - solid */}
          <div className="absolute left-0 top-0 bottom-2 w-px bg-gray-200 dark:bg-gray-700" />
          {children}
        </div>
      )}
    </div>
  )
}

interface SubNavItemProps {
  href: string
  icon: React.ElementType
  label: string
  isActive?: boolean
}

function SubNavItem({ href, icon: Icon, label, isActive }: SubNavItemProps) {
  return (
    <Link
      to={href}
      className={cx(
        "group relative flex items-center gap-3 rounded-md px-3 py-2 text-sm tracking-tight transition-all duration-100",
        isActive
          ? "bg-orange-50 text-orange-600 font-medium dark:bg-orange-950 dark:text-orange-400"
          : "text-gray-600 hover:bg-gray-100 hover:text-gray-900 dark:text-gray-400 dark:hover:bg-gray-800 dark:hover:text-gray-100"
      )}
    >
      <Icon className="size-[18px] shrink-0" />
      <span>{label}</span>
    </Link>
  )
}


export function SidebarProvider({ children }: { children: React.ReactNode }) {
  const [isCollapsed, setIsCollapsed] = useState(false)

  return (
    <SidebarContext.Provider value={{ isCollapsed, setIsCollapsed }}>
      {children}
    </SidebarContext.Provider>
  )
}

export function Sidebar() {
  const { isCollapsed } = useSidebar()
  const location = useLocation()
  const pathname = location.pathname
  const { tenants, selectedIndex, selectedTenant, setSelectedIndex } = useTenant()
  const isMultiTenant = tenants.length > 1

  const isViewActive = pathname.startsWith("/view")
  const currentView = pathname.split("/").pop()

  const displayTenantName = selectedTenant?.TenantName || selectedTenant?.TenantId || "Tenant"


  return (
    <div
      className={cx(
        "relative flex h-full flex-col border-r border-gray-200 bg-white transition-all duration-300 dark:border-gray-800 dark:bg-black",
        isCollapsed ? "w-16" : "w-64"
      )}
    >
      {/* Logo Header */}
      <div className={cx(
        "flex h-16 items-center gap-3 border-b border-gray-200 dark:border-gray-800",
        isCollapsed ? "justify-center px-2" : "px-4"
      )}>
        <Link to="/" onClick={scrollReportToTop} aria-label="Home" className="flex items-center gap-3 overflow-hidden">
          <span className="sr-only">M365Advisor Logo (go home)</span>
          <img
            src={m365advisorLogo}
            alt="M365Advisor"
            width={32}
            height={32}
            className="h-8 w-8 shrink-0"
          />
          {!isCollapsed && (
            <div className="flex flex-col overflow-hidden">
              <span className="text-sm font-semibold tracking-tight text-gray-900 dark:text-gray-100">M365Advisor</span>
              <span className="truncate text-xs tracking-tight text-gray-500 dark:text-gray-400">
                {displayTenantName}
              </span>
            </div>
          )}
        </Link>
      </div>

      {/* Tenant Selector (multi-tenant only) */}
      {isMultiTenant && !isCollapsed && (
        <div className="border-b border-gray-200 p-3 dark:border-gray-800">
          <div className="mb-1 px-3 text-xs font-medium uppercase tracking-wider text-gray-400 dark:text-gray-500">
            Tenants
          </div>
          <div className="space-y-0.5">
            {tenants.map((tenant, index) => (
              <button
                key={tenant.TenantId || index}
                onClick={() => setSelectedIndex(index)}
                className={cx(
                  "flex w-full items-center gap-3 rounded-md px-3 py-2 text-sm font-medium tracking-tight transition-all duration-100",
                  index === selectedIndex
                    ? "bg-orange-50 text-orange-600 dark:bg-orange-950 dark:text-orange-400"
                    : "text-gray-700 hover:bg-gray-100 hover:text-gray-900 dark:text-gray-300 dark:hover:bg-gray-800 dark:hover:text-gray-100"
                )}
              >
                <Building2 className="size-[18px] shrink-0" />
                <span className="truncate">{tenant.TenantName || tenant.TenantId || `Tenant ${index + 1}`}</span>
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Tenant Selector (collapsed, multi-tenant only) */}
      {isMultiTenant && isCollapsed && (
        <div className="border-b border-gray-200 p-2 dark:border-gray-800">
          {tenants.map((tenant, index) => (
            <button
              key={tenant.TenantId || index}
              onClick={() => setSelectedIndex(index)}
              title={tenant.TenantName || tenant.TenantId || `Tenant ${index + 1}`}
              className={cx(
                "flex w-full items-center justify-center rounded-md p-2 transition-all duration-100",
                index === selectedIndex
                  ? "bg-orange-50 text-orange-600 dark:bg-orange-950 dark:text-orange-400"
                  : "text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800"
              )}
            >
              <Building2 className="size-[18px]" />
            </button>
          ))}
        </div>
      )}

      {/* Navigation */}
      <nav className="flex-1 space-y-1 overflow-y-auto p-3">
        <NavItem
          href="/"
          icon={House}
          label="Home"
          isActive={pathname === "/"}
          isCollapsed={isCollapsed}
          onClick={scrollReportToTop}
        />

        <NavGroup
          icon={Eye}
          label="View"
          isActive={isViewActive}
          isCollapsed={isCollapsed}
          defaultOpen={true}
        >
          <SubNavItem
            href="/view/markdown"
            icon={FileText}
            label="Markdown"
            isActive={currentView === "markdown"}
          />
          <SubNavItem
            href="/view/excel"
            icon={Table}
            label="Excel"
            isActive={currentView === "excel"}
          />
          <SubNavItem
            href="/view/print"
            icon={Printer}
            label="Print"
            isActive={currentView === "print"}
          />
        </NavGroup>
      </nav>

    </div>
  )
}

export default Sidebar
