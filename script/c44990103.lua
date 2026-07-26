--满怀希望的树妖（重置版）
local s,id=GetID()
function s.initial_effect(c)
	-- 记述标记
	aux.AddCodeList(c,44990100)
	-- ① 手卡特召（空场）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon1)
	c:RegisterEffect(e1)
	-- ② 召唤·特召成功时（一回合一次）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
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
	-- ②发动后自肃（本回合非风属性不能特召）
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,0)
	e6:SetCondition(s.splimcon)
	e6:SetTarget(s.splimit)
	c:RegisterEffect(e6)
end

function s.spcon1(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+200)==0
end
function s.filter2(c)
	return aux.IsCodeListed(c,44990100)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>=3
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+200)>0 then return end
	local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<3 then return end
	local selgroup=Group.CreateGroup()
	local cg=g:Clone()
	for i=1,3 do
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		local tc=cg:Select(tp,1,1,nil):GetFirst()
		selgroup:AddCard(tc)
		cg:Remove(Card.IsCode,nil,tc:GetCode())
	end
	Duel.ConfirmCards(1-tp,selgroup)
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,2))
	local oc=selgroup:Select(1-tp,1,1,nil):GetFirst()
	Duel.SendtoHand(oc,nil,REASON_EFFECT)
	selgroup:RemoveCard(oc)
	Duel.SendtoDeck(selgroup,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1)
	Duel.RegisterFlagEffect(tp,id+300,RESET_PHASE+PHASE_END,0,1)
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