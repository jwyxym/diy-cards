--沉溺的实验体
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,57310005)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep2(c,s.mfilter,2,127,true)
	--splimit
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--spsummon condition
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(s.splimit)
	c:RegisterEffect(e2)
	--summon process
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	s.register_tier_effects(c)
end
function s.mfilter(c)
	return c:IsCode(57310005)
end
function s.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and Duel.GetFlagEffect(sp,id)==0
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or c:GetFlagEffect(id)>0
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.spfilter(c,tp,sc)
	return c:IsRace(RACE_ILLUSION) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(2) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0 and (c:IsControler(tp) or c:IsFaceup())
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if  Duel.GetFlagEffect(tp,id)>0 then return false end
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil,tp,c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,tp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
	local g=e:GetLabelObject()
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
function s.sumreg(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local code=e:GetLabel()
	while tc do
	if tc:GetOriginalCode()==code then
	Duel.RegisterFlagEffect(rp,code,nil,0,1)
	end
	tc=eg:GetNext()
	end
end
function s.register_tier_effects(c)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetLabel(57310005)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetOperation(s.sumreg)
		Duel.RegisterEffect(ge1,0)
	end
	local e11=Effect.CreateEffect(c)
	e11:SetDescription(aux.Stringid(id,0))
	e11:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e11:SetType(EFFECT_TYPE_IGNITION)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCountLimit(1)
	e11:SetCondition(s.cond_tier1)
	e11:SetTarget(s.tg_tier1)
	e11:SetOperation(s.op_tier1)
	c:RegisterEffect(e11)
	local e13=Effect.CreateEffect(c)
	e13:SetType(EFFECT_TYPE_SINGLE)
	e13:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e13:SetRange(LOCATION_MZONE)
	e13:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e13:SetCondition(s.cond_tier3)
	e13:SetValue(aux.tgoval)
	c:RegisterEffect(e13)
	local e13b=e13:Clone()
	e13b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e13b:SetValue(1)
	c:RegisterEffect(e13b)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.cond_tier5)
	e5:SetTarget(s.tg_tier5)
	e5:SetOperation(s.op_tier5)
	c:RegisterEffect(e5)
end

function s.cond_tier1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,57310005)>=1
end
function s.cond_tier3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,57310005)>=3
end
function s.cond_tier5(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and Duel.IsChainDisablable(ev) and re:IsActiveType(TYPE_MONSTER)
		and Duel.GetTurnPlayer()~=tp and Duel.GetFlagEffect(tp,57310005)>=5
end

function s.thfilter(c)
	return c:IsType(TYPE_SPELL) and aux.IsCodeOrListed(c,57310005) and c:IsAbleToHand()
end
function s.tg_tier1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op_tier1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.tg_tier5(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.op_tier5(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,99,nil)
	local dt=Duel.Destroy(g,REASON_EFFECT)
	if dt~=0 then
		if Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local g2=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,dt,nil)
			if #g2>0 then Duel.Destroy(g2,REASON_EFFECT) end
		end
	 end
end