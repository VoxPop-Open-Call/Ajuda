import React from "react";

import { ColumnFilterValue } from "@coreui/react-pro/src/components/smart-table/types";
import { useNavigate } from "react-router";

import { UserProps } from "../../../Controllers/UserControllers/UsersApi";
import TableComponent from "../../common/TableComponent/TableComponent";
import {
  userColumns,
  verifiedColumnBadge,
} from "../../common/TableComponent/TableComponentHelperFunctions";

import styles from "./usersTableComponent.module.scss";

interface UsersTableComponentProps {
  tableData: Array<UserProps>;
  pagination: {
    limit: number;
    offset: number;
    orderBy: string;
    filter: ColumnFilterValue;
  };
  setPagination: React.Dispatch<
    React.SetStateAction<{
      limit: number;
      offset: number;
      orderBy: string;
      filter: ColumnFilterValue;
    }>
  >;
}

const UsersTableComponent: React.FC<UsersTableComponentProps> = ({
  tableData,
  pagination,
  setPagination,
}: UsersTableComponentProps): JSX.Element => {
  const navigate = useNavigate();
  const columnProps = {
    verified: (user: { verified: boolean }): JSX.Element =>
      verifiedColumnBadge(user.verified),
    actions: (user: UserProps) => (
      <td>
        <div
          className={styles.buttonStyle}
          onClick={() => {
            navigate(`/user/${user.id}`, {
              state: { isVolunteer: false },
            });
          }}
        >
          Show
        </div>
      </td>
    ),
  };

  const renderDataTable = (): JSX.Element => (
    <>
      <TableComponent
        tableData={tableData}
        tableColumnProps={columnProps}
        tableColumnsVisibility={userColumns}
        pagination={pagination}
        setPagination={setPagination}
      />
    </>
  );

  return <div>{renderDataTable()}</div>;
};

export default UsersTableComponent;
