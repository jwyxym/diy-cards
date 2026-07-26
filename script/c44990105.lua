--欢笑的姐妹（重置版）
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,44990100)
	-- ① 召唤·特召成功时，从卡组盖放记述魔陷，自肃
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ② 主阶特召记述龙族（手卡·墓地）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.con2)
	e3:SetTarget(s.tg2)
	e3:SetOperation(s.op2)
	c:RegisterEffect(e3)
	-- ③ 等级当作8/9（深渊鲨模式）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_XYZ_LEVEL)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.xyzlv)
	e4:SetLabel(8)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetLabel(9)
	c:RegisterEffect(e5)
	-- ①发动后自肃（非风属性不能特召）
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,0)
	e6:SetCondition(s.splimcon)
	e6:SetTarget(s.splimit)
	c:RegisterEffect(e6)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+200)==0
end
function s.filter1(c)
	return aux.IsCodeListed(c,44990100) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
		return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.RegisterFlagEffect(tp,id+300,RESET_PHASE+PHASE_END,0,1)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+200)>0 then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
		Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1)
	end
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+400)==0
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and aux.IsCodeListed(c,44990100) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		Duel.RegisterFlagEffect(tp,id+400,RESET_PHASE+PHASE_END,0,1)
	end
end

function s.xyzlv(e,c,rc)
	if rc:IsSetCard(0xcf1) then
		return c:GetLevel()+0x10000*e:GetLabel()
	else
		return c:GetLevel()
	end
end

function s.splimcon(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id+300)>0
end
function s.splimit(e,c,tp,sumtp)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end