select * from netflix_tb;

select count(*) from netflix_tb;

select distinct type from netflix_tb;

select type, count(*) from netflix_tb
group by type;