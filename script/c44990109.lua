--觉醒巨龙 伊瑟拉（修正③条件为记述伊瑟拉）
local s,id,o=GetID()
function s.initial_effect(c)
	-- 超量召唤手续（兼容树妖、姐妹、龙群先锋）
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.xyzcon)
	e1:SetOperation(s.xyzop)
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)

	-- ① 卡名在场上·墓地当作「伊瑟拉」
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetValue(44990100)
	c:RegisterEffect(e2)

	-- ② 对方发动怪兽效果时，去2素材无效并破坏
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)

	-- ③ 自己发动记述「伊瑟拉」的魔法卡时，吸收并除外卡组顶
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)  -- 1回合1次
	e4:SetCondition(s.matcon)
	e4:SetTarget(s.mattg)
	e4:SetOperation(s.matop)
	c:RegisterEffect(e4)
end

-- ===== 超量素材 =====
function s.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsFaceup()
		and (c:IsLevel(9) or c:IsCode(44990103) or c:IsCode(44990105) or c:IsCode(44990108))
end
function s.mlvl(c)
	if c:IsCode(44990103) or c:IsCode(44990105) or c:IsCode(44990108) then return 9 end
	return c:GetLevel()
end
function s.mcheck(g)
	if #g~=2 then return false end
	local sum=0
	for tc in aux.Next(g) do
		sum=sum+s.mlvl(tc)
	end
	return sum==18
end
function s.xyzcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<0 then return false end
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(s.mcheck,2,2)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local sg=g:SelectSubGroup(tp,s.mcheck,true,2,2)
	if sg and #sg==2 then
		Duel.Overlay(c,sg)
	end
end

-- ===== ② 无效怪兽效果 =====
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER)
		and Duel.IsChainDisablable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		local tc=re:GetHandler()
		if tc and tc:IsRelateToEffect(re) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end

-- ===== ③ 吸收魔法卡 + 除外卡组顶（改为记述检查） =====
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	if not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==tp) then return false end
	local rc=re:GetHandler()
	if not rc or not rc:IsType(TYPE_SPELL) then return false end
	-- 检查是否记述「伊瑟拉」（手动列表 + 字段备用）
	return s.IsYseraListed(rc)
end

function s.IsYseraListed(c)
	-- 已知记述卡号（包括伊瑟拉本体、莎拉达希尔、阿梅达希尔、梦境等）
	local listed_ids = {44990100, 44990101, 44990102, 44990104, 44990105, 44990106, 44990107, 44990108, 44990109}
	for _, code in ipairs(listed_ids) do
		if c:IsCode(code) then return true end
	end
	-- 退化为字段 0xcf1（如果你的梦境等已经设好字段也能生效）
	if c:IsSetCard(0xcf1) then return true end
	-- 最后尝试官方记述函数（如果存在）
	if aux.IsCodeListed and aux.IsCodeListed(c,44990100) then return true end
	return false
end

function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsCanOverlay() end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	re:GetHandler():CreateEffectRelation(e)
end

function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=re:GetHandler()
	if c:IsRelateToChain() and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		tc:CancelToGrave()
		if Duel.Overlay(c,tc)~=0 then
			local g=Duel.GetDecktopGroup(1-tp,1)
			if #g>0 then
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end