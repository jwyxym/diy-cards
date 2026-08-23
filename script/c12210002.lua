-- 卡密：12210002
-- 阶级3 超量怪兽 3星怪兽×3
local s,id=GetID()
function s.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	--xyz summon
	aux.AddXyzProcedure(c,nil,3,3)
	c:EnableReviveLimit()

--抗性
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
--不能做素材	
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--to deck
	local e2=e0:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e2)
	local e3=e0:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e3)
	local e4=e0:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e4:SetValue(s.fuslimit)
	c:RegisterEffect(e4)
	local e9=e0:Clone()
	e9:SetCode(EFFECT_UNRELEASABLE_SUM)
	c:RegisterEffect(e9)
	--吸素材
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(12210002,1))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(5)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)

--③ 自己·对方结束阶段 素材5张以上必定自毁
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(12210002,2))
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.descon)
	e6:SetOperation(s.desop)
	c:RegisterEffect(e6)
end

--抗性筛选
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

--融合素材限制
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end

--======== 关键：新增筛选函数，排除自身 ========
function s.ofilter(c,e)
	-- 不能选自己，只筛选场上/魔陷区自己的卡
	return c~=e:GetHandler()
end

--效果目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) 
		and Duel.IsExistingMatchingCard(s.ofilter,tp,LOCATION_SZONE+LOCATION_MZONE,0,1,nil,e) end
end

--效果处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		--调用筛选，自带排除自身
		local g=Duel.SelectMatchingCard(tp,s.ofilter,tp,LOCATION_SZONE+LOCATION_MZONE,0,1,1,nil,e)
		local tc=g:GetFirst()
		if tc then
			Duel.Overlay(c,tc)
		end
	end
end

--③ 自毁条件：超量素材≥5
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOverlayCount()>=5
end

--③ 自毁处理
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.Destroy(c,REASON_EFFECT)
	end
end
