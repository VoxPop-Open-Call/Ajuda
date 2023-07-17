import React from "react";

import { ColumnFilterValue } from "@coreui/react-pro/src/components/smart-table/types";

import { RequestProps } from "../../../Controllers/RequestsController/RequestsApi";
import TableComponent from "../../common/TableComponent/TableComponent";
import { requestColumns } from "../../common/TableComponent/TableComponentHelperFunctions";
import {
  returnRequestRating,
  returnVolunteerName,
} from "../RequestComponentsHelperFunctions";

interface RequestsTableComponentProps {
  tableData: Array<RequestProps>;
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

const RequestsTableComponent: React.FC<RequestsTableComponentProps> = ({
  tableData,
  pagination,
  setPagination,
}: RequestsTableComponentProps): JSX.Element => {
  const columnProps = {
    requester: (entry: RequestProps): JSX.Element => (
      <td>{entry.requester?.name}</td>
    ),
    volunteer: (entry: RequestProps): JSX.Element => (
      <td>{returnVolunteerName(entry?.acceptedVolunteer)}</td>
    ),
    taskType: (entry: RequestProps): JSX.Element => (
      <td>{entry.taskType?.code}</td>
    ),
    rate: (entry: RequestProps): JSX.Element => (
      <td>{returnRequestRating(entry.assignments)}</td>
    ),
  };

  const renderDataTable = (): JSX.Element => {
    return (
      <>
        <TableComponent
          tableData={tableData}
          tableColumnProps={columnProps}
          tableColumnsVisibility={requestColumns}
          pagination={pagination}
          setPagination={setPagination}
        />
      </>
    );
  };

  return <div>{renderDataTable()}</div>;
};

export default RequestsTableComponent;
