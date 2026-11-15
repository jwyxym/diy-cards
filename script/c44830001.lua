--根绝验证·兰佩吉
local s,id,o=GetID()
local RENMIE=0x7ce1
local SHEN=57330010
local SHI=44830040

function s.initial_effect(c)
	aux.AddCodeList(c,SHEN)
	--①：把手卡的这张卡给对方观看，把自己手卡·场上的1张其他的魔法·怪兽卡除外才能发动。从卡组把1张「人灭」卡加入手卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--②：自己主要阶段才能发动。对方场上2张卡除外。这个回合，自己是已把「根绝验证·兰佩吉」的①的效果发动过的场合，再把对方的基本分变成一半。这个回合，对方受到的效果伤害变成0
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1000)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--③：「人灭」卡的效果把对方的怪兽除外时才能发动。对方把原本卡名和那个效果除外的卡相同的卡从自身的手卡·卡组·额外卡组全部除外
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.con3)
	e3:SetTarget(s.tg3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end

--共通：这张卡的效果发动的回合，自己不是恶魔族怪兽不能特殊召唤
function s.reglimit(e,tp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	if not c:IsRace(RACE_FIEND) then return true end
	if not c:IsType(TYPE_FUSION) then return false end
	--不用卡的效果的特殊召唤（接触融合等召唤规则）也禁止
	return se==nil or se:GetCode()==EFFECT_SPSUMMON_PROC
end

--①
function s.costfilter(c,e,tp)
	if c:IsLocation(LOCATION_GRAVE) then
		return e:GetHandler():IsSetCard(RENMIE) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(SHI,tp)
	end
	return c~=e:GetHandler() and (c:IsType(TYPE_MONSTER) or c:IsType(TYPE_SPELL))
		and c:IsAbleToRemoveAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.ConfirmCards(1-tp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local te=tc:IsHasEffect(SHI,tp)
	if te then
		te:UseCountLimit(tp)
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
	end
end
function s.thfilter(c)
	return c:IsSetCard(RENMIE) and c:IsAbleToHand()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	s.reglimit(e,tp)
	Duel.RegisterFlagEffect(tp,id+2000,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--②
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,2,nil) end
	s.reglimit(e,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,1-tp,LOCATION_ONFIELD)
end
function s.damval(e,re,val,r,rp,rc)
	if r&REASON_EFFECT~=0 then return 0 end
	return val
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,2,2,nil)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
	if Duel.GetFlagEffect(tp,id+2000)~=0 then
		Duel.BreakEffect()
		local lp=Duel.GetLP(1-tp)
		Duel.SetLP(1-tp,math.ceil(lp/2))
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetTargetRange(0,1)
		e1:SetValue(s.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

--③
function s.rmfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return r&REASON_EFFECT~=0 and rc:IsSetCard(RENMIE) and rc:IsControler(tp)
		and eg:IsExists(s.rmfilter,1,nil,1-tp)
end
function s.bffilter(c,codes)
	return codes[c:GetOriginalCode()] and not c:IsForbidden()
end
function s.getcodes(eg,tp)
	local codes={}
	local ct=0
	local g=eg:Filter(s.rmfilter,nil,1-tp)
	for tc in aux.Next(g) do
		local code=tc:GetOriginalCode()
		if not codes[code] then
			codes[code]=true
			ct=ct+1
		end
	end
	return codes,ct
end
function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local codes,ct=s.getcodes(eg,tp)
		return ct>0 and Duel.IsExistingMatchingCard(s.bffilter,1-tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,codes)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local codes,ct=s.getcodes(eg,tp)
	if ct==0 then return end
	local rg=Duel.GetMatchingGroup(s.bffilter,1-tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,nil,codes)
	if rg:GetCount()>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
