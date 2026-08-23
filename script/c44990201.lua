--死亡之翼
local s,id=GetID()
function s.initial_effect(c)
	-- 有「死亡之翼」的卡名记述（自身声明，供其他卡检查）
	aux.AddCodeList(c,44990201)

	-- 融合召唤：有「死亡之翼」的卡名记述的怪兽×4只以上
	aux.AddFusionProcFunRep(c,s.ffilter,4,true)
	c:EnableReviveLimit()

	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.maincon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)

	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end

-- 融合素材条件
function s.ffilter(c)
	return aux.IsCodeListed(c,44990201) and c:IsType(TYPE_MONSTER)
end

function s.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end

function s.hspfilter(c,tp,fc)
	return c:IsFaceup() and c:IsReleasable(REASON_SPSUMMON)
end

function s.dcfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if re and eg:IsExists(s.dcfilter,1,nil) and re:GetHandler():IsCode(44990200) then
		Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
	end
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if Duel.GetFlagEffect(0,id)==0 then return false end
	return Duel.IsExistingMatchingCard(s.hspfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,c)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp,c)
	if #g==0 then return false end
	g:KeepAlive()
	e:SetLabelObject(g)
	return true
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if g and #g>0 then
		Duel.Release(g,REASON_SPSUMMON)
	end
end

function s.immval(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer() and re:IsActivated()
end

function s.maincon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

function s.exfilter(c)
	return c:IsAbleToRemove()
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	end
	local ct=#g
	if ct==0 then return end
	local total=Duel.GetMatchingGroupCount(Card.IsAbleToRemove,1-tp,LOCATION_HAND,0,nil)
		+Duel.GetMatchingGroupCount(Card.IsAbleToRemove,1-tp,LOCATION_EXTRA,0,nil)
	if total<ct then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	local exc_g=Duel.SelectMatchingCard(1-tp,s.exfilter,1-tp,LOCATION_HAND+LOCATION_EXTRA,0,ct,ct,nil)
	if #exc_g>0 then
		Duel.Remove(exc_g,POS_FACEUP,REASON_EFFECT)
	end
end