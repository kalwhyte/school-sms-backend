// import { Controller } from '@nestjs/common';

// @Controller('students')
// export class StudentsExtraController {}
// import {
//   Get,
//   Post,
//   Body,
//   Param,
//   Patch,
//   Delete,
//   UseGuards,
// } from '@nestjs/common';
// import { RolesGuard } from '../../auth/guards/roles.guard';
// import { Roles } from '../../auth/decorators/roles.decorator';
// import { Role } from '../../auth/enums/role.enum';

// @Controller('students-management')
// @UseGuards(RolesGuard)
// export class StudentsManagementController {
//   @Get()
//   @Roles(Role.ADMIN, Role.TEACHER)
//   findAll() {
//     return 'This action returns all students';
//   }

//   @Get(':id')
//   @Roles(Role.ADMIN, Role.TEACHER, Role.STUDENT)
//   findOne(@Param('id') id: string) {
//     return `This action returns student #${id}`;
//   }

//   @Post()
//   @Roles(Role.ADMIN)
//   create(@Body() createStudentDto: any) {
//     return 'This action adds a new student';
//   }

//   @Patch(':id')
//   @Roles(Role.ADMIN)
//   update(@Param('id') id: string, @Body() updateStudentDto: any) {
//     return `This action updates student #${id}`;
//   }

//   @Delete(':id')
//   @Roles(Role.ADMIN)
//   remove(@Param('id') id: string) {
//     return `This action removes student #${id}`;
//   }
// }
