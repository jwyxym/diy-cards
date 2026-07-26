--纳拉雷克斯 龙群先锋（重置版）
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,44990100)
	-- ① 展示自身检索记述卡并特召
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	-- ② 主阶展示3张对方随机选1加入手卡，自肃
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	-- ③ 等级当作9（深渊鲨模式，只提供9）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_XYZ_LEVEL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.xyzlv)
	e3:SetLabel(9)
	c:RegisterEffect(e3)
	-- ②发动后自肃
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetCondition(s.splimcon)
	e4:SetTarget(s.splimit)
	c:RegisterEffect(e4)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+200)==0
end
function s.thfilter(c)
	return aux.IsCodeListed(c,44990100) and c:IsAbleToHand()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetFlagEffect(tp,id+200)>0 then return false end
		if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then return false end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		if not e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
		return true
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+200)>0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
		Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1)
	end
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+300)==0
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(aux.IsCodeListed,tp,LOCATION_DECK,0,nil,44990100)
		return g:GetClassCount(Card.GetCode)>=3
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+300)>0 then return end
	local g=Duel.GetMatchingGroup(aux.IsCodeListed,tp,LOCATION_DECK,0,nil,44990100)
	if g:GetClassCount(Card.GetCode)<3 then return end
	local selgroup=Group.CreateGroup()
	local cg=g:Clone()
	for i=1,3 do
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local tc=cg:Select(tp,1,1,nil):GetFirst()
		selgroup:AddCard(tc)
		cg:Remove(Card.IsCode,nil,tc:GetCode())
	end
	Duel.ConfirmCards(1-tp,selgroup)
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,3))
	local rc=selgroup:RandomSelect(tp,1):GetFirst()
	Duel.SendtoHand(rc,nil,REASON_EFFECT)
	selgroup:RemoveCard(rc)
	Duel.SendtoDeck(selgroup,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.RegisterFlagEffect(tp,id+300,RESET_PHASE+PHASE_END,0,1)
	Duel.RegisterFlagEffect(tp,id+400,RESET_PHASE+PHASE_END,0,1)
end

function s.xyzlv(e,c,rc)
	if rc:IsSetCard(0xcf1) then
		return c:GetLevel()+0x10000*e:GetLabel()
	else
		return c:GetLevel()
	end
end

function s.splimcon(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id+400)>0
end
function s.splimit(e,c,tp,sumtp)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end