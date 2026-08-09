-- 纹章的复苏 (ID: 98765406)
local s,id,o=GetID()
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从自己的卡组·额外卡组把 1 只「纹章兽」怪兽或念动力族超量怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH) -- 这个卡名的卡 1 回合只能发动 1 张
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- ①-2：常驻防响应监视器（只要在场地区域存在，全回合生效，每回合限 1 次弹窗保护）
	local e1_2=Effect.CreateEffect(c)
	e1_2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1_2:SetCode(EVENT_CHAINING)
	e1_2:SetRange(LOCATION_FZONE)
	e1_2:SetOperation(s.chainop)
	c:RegisterEffect(e1_2)

	-- ②：以怪兽 3 只以上为素材的「No.」超量怪兽进行超量召唤的场合，自己场上的 1 只「纹章兽」怪兽可以作为 2 只数量的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1)) -- 触发弹窗：关联数据库第 2 行的询问文本
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DOUBLE_XMATERIAL)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.xfilter)
	e2:SetValue(id)
	e2:SetCountLimit(1,id+o*100) -- 限制 1 回合 1 次弹窗使用
	c:RegisterEffect(e2)
end

-- ==================== ① 效果：发动送墓与弹窗防响应 ====================
function s.sendfilter(c)
	return (c:IsSetCard(0x76) or (c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_XYZ)))
		and c:IsAbleToGrave()
end

function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.sendfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	-- 标记：本卡成功发动，开启本回合防响应许可
	Duel.RegisterFlagEffect(tp,id+o*200,RESET_PHASE+PHASE_END,0,1)
end

function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+o*200)==0 or Duel.GetFlagEffect(tp,id)>0 then return end
	local rc=re:GetHandler()
	if ep==tp and (rc:IsSetCard(0x76) or rc:IsSetCard(0x92) or (rc:IsSetCard(0x48) and rc:IsType(TYPE_XYZ))) then
		-- 读取数据库第 4 行 (aux.Stringid(id, 3)) 进行防响应弹窗询问
		if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
			Duel.SetChainLimit(s.chainlm)
		end
	end
end

function s.chainlm(re,rp,tp)
	return tp==rp
end

-- ==================== ② 效果：双倍素材赋予（无递归死循环） ====================
function s.xfilter(e,c)
	if not c then return false end
	if c:IsType(TYPE_XYZ) then
		return c:IsSetCard(0x48)
	else
		return c:IsSetCard(0x76) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
	end
end