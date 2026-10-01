-- 烬雪的交织·薇缇雅
local s,id,o=GetID()
function s.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c,false)
	--fusion material（正规融合：通常怪兽2只）
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.fusmatfilter,2,false)
	--联系融合：解放自己场上2张「烬雪」怪兽卡·通常怪兽卡（一回合一次）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCountLimit(1,id)
	e0:SetCondition(s.contactcon)
	e0:SetTarget(s.contacttg)
	e0:SetOperation(s.contactop)
	c:RegisterEffect(e0)
	--怪兽①
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,10))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	--怪兽②
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,id+2)
	e4:SetCondition(s.pencon)
	e4:SetTarget(s.pentg)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
end

-- 正规融合素材：通常怪兽
function s.fusmatfilter(c)
	return c:IsType(TYPE_NORMAL)
end

-- 联系融合素材：烬雪怪兽卡 或 通常怪兽卡（含后场）
function s.contactmatfilter(c,tp)
	if not c:IsControler(tp) or not c:IsReleasable() then return false end
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsSetCard(0xe93) or c:IsType(TYPE_NORMAL)
	else
		return c:IsSetCard(0xe93) or (c:GetOriginalType()&TYPE_NORMAL>0)
	end
end
function s.contactcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.contactmatfilter,tp,LOCATION_ONFIELD,0,2,nil,tp)
end
function s.contacttg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.contactmatfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	if g:GetCount()<2 then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=g:Select(tp,2,2,nil)
	if #sg<2 then return false end
	sg:KeepAlive()
	e:SetLabelObject(sg)
	return true
end
function s.contactop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Release(g,REASON_SPSUMMON+REASON_MATERIAL)
	g:DeleteGroup()
end

-- 怪兽①：从额外卡组（表侧）特召1只烬雪怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xe93) and c:IsFaceup() and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 从自己场上选烬雪灵摆怪兽贴P
function s.pfilter(c)
	return c:IsSetCard(0xe93) and c:IsType(TYPE_PENDULUM) and c:IsFaceup()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=sg:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	local pg=Duel.GetMatchingGroup(s.pfilter,tp,LOCATION_ONFIELD,0,nil)
	if pg:GetCount()>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local pgsel=pg:Select(tp,1,1,nil)
		if pgsel:GetCount()>0 then
			local tc1=pgsel:GetFirst()
			Duel.MoveToField(tc1,tp,tp,LOCATION_PZONE,POS_FACEUP,false)
			tc1:SetStatus(STATUS_EFFECT_ENABLED,true)
		end
	end
end

-- 怪兽②：被破坏时在P区放置
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_GRAVE)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsLocation(LOCATION_GRAVE) then return end
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,false)
	c:SetStatus(STATUS_EFFECT_ENABLED,true)
end