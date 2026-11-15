--人灭三恶·兰佩吉
local s,id,o=GetID()
local RENMIE=0x7ce1
local SHI=44830040

function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.matfilter,3,true)
	--①：场上的这张卡不会被效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--②：对方把卡的效果发动时才能发动。那个效果无效。也能把自己手卡·场上的2张其他的魔法·怪兽卡除外来发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1000)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--③：「人灭」卡的效果把对方的怪兽除外时适用。对方把原本卡名和那个效果除外的卡相同的卡从自身的手卡·卡组·额外卡组全部除外
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.con3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end

function s.matfilter(c)
	return c:IsSetCard(RENMIE) and c:IsType(TYPE_MONSTER)
end

--②
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	return Duel.IsChainNegatable(ev)
end
function s.costfilter(c,ec,tp)
	if c:IsLocation(LOCATION_GRAVE) then
		return c:IsAbleToRemoveAsCost() and c:IsHasEffect(SHI,tp)
	end
	return c~=ec and (c:IsType(TYPE_MONSTER) or c:IsType(TYPE_SPELL)) and c:IsAbleToRemoveAsCost()
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	e:SetLabel(0)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,nil,c,tp)
	if g:GetCount()<2 then return end
	if Duel.SelectOption(tp,aux.Stringid(id,8),aux.Stringid(id,9))~=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:Select(tp,2,2,nil)
	if sg:GetCount()<2 then return end
	for tc in aux.Next(sg) do
		local te=tc:IsHasEffect(SHI,tp)
		if te then
			te:UseCountLimit(tp)
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		else
			Duel.Remove(tc,POS_FACEUP,REASON_COST)
		end
	end
	e:SetLabel(1)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev)==0 then return end
	if e:GetLabel()~=1 then return end
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil,TYPE_MONSTER)
	if g:GetCount()==0 then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,10)) then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=g:Select(tp,1,1,nil)
	if rg:GetCount()>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
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
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local codes,ct=s.getcodes(eg,tp)
	if ct==0 then return end
	local rg=Duel.GetMatchingGroup(s.bffilter,1-tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,nil,codes)
	if rg:GetCount()>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
